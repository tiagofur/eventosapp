package services

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"time"

	"github.com/google/uuid"
	"github.com/sideshow/apns2"
	"github.com/tiagofur/solennix-backend/internal/models"
)

// LiveActivityTokenStore is the subset of the live activity token repo
// the service needs. Defined here so the service can be tested in isolation.
type LiveActivityTokenStore interface {
	GetByEventID(ctx context.Context, eventID uuid.UUID) ([]models.LiveActivityToken, error)
	DeleteByToken(ctx context.Context, pushToken string) error
}

// LiveActivityContentState mirrors the iOS SolennixEventAttributes.ContentState.
// Field names MUST match the JSON keys the iOS struct decodes (camelCase).
type LiveActivityContentState struct {
	Status         string    `json:"status"`
	StartTime      time.Time `json:"startTime"`
	ElapsedMinutes int       `json:"elapsedMinutes"`
	StatusLabel    string    `json:"statusLabel"`
}

// LiveActivityEvent is the value of the "event" field in the APNs payload.
type LiveActivityEvent string

const (
	LiveActivityEventUpdate LiveActivityEvent = "update"
	LiveActivityEventEnd    LiveActivityEvent = "end"
)

// LiveActivityService sends APNs push updates to running iOS Live Activities.
type LiveActivityService struct {
	tokenRepo  LiveActivityTokenStore
	apnsClient *apns2.Client
	apnsTopic  string // bundle id; we append .push-type.liveactivity for the actual topic
	enabled    bool
}

// NewLiveActivityService wires the service. Reuses the APNs client and bundle id
// from the existing PushService configuration. If APNs isn't configured the
// service is disabled and all sends become no-ops + logs.
func NewLiveActivityService(tokenRepo LiveActivityTokenStore, pushService *PushService) *LiveActivityService {
	s := &LiveActivityService{tokenRepo: tokenRepo}
	if pushService != nil {
		s.apnsClient = pushService.apnsClient
		s.apnsTopic = pushService.apnsTopic
	}
	s.enabled = s.apnsClient != nil && s.apnsTopic != ""
	if !s.enabled {
		slog.Warn("Live Activity service disabled: APNs not configured")
	}
	return s
}

// IsEnabled returns whether the service can actually send pushes.
func (s *LiveActivityService) IsEnabled() bool {
	return s.enabled
}

// PushUpdate sends a content-state update to every registered token for an event.
// Tokens that APNs rejects as expired/invalid are removed from the store.
func (s *LiveActivityService) PushUpdate(ctx context.Context, eventID uuid.UUID, state LiveActivityContentState) error {
	return s.push(ctx, eventID, LiveActivityEventUpdate, state, nil)
}

// PushEnd sends a final state and dismisses the activity. dismissAt may be nil
// to use the default dismissal policy.
func (s *LiveActivityService) PushEnd(ctx context.Context, eventID uuid.UUID, state LiveActivityContentState, dismissAt *time.Time) error {
	return s.push(ctx, eventID, LiveActivityEventEnd, state, dismissAt)
}

func (s *LiveActivityService) push(ctx context.Context, eventID uuid.UUID, event LiveActivityEvent, state LiveActivityContentState, dismissAt *time.Time) error {
	if !s.enabled {
		slog.Info("Live Activity push skipped (disabled)", "event_id", eventID, "event", event)
		return nil
	}

	tokens, err := s.tokenRepo.GetByEventID(ctx, eventID)
	if err != nil {
		return fmt.Errorf("fetch live activity tokens: %w", err)
	}
	if len(tokens) == 0 {
		return nil
	}

	payloadBytes, err := buildLiveActivityPayload(event, state, dismissAt)
	if err != nil {
		return fmt.Errorf("build payload: %w", err)
	}

	topic := s.apnsTopic + ".push-type.liveactivity"
	for _, t := range tokens {
		notification := &apns2.Notification{
			DeviceToken: t.PushToken,
			Topic:       topic,
			PushType:    apns2.PushTypeLiveActivity,
			Priority:    apns2.PriorityHigh,
			Payload:     payloadBytes,
		}

		res, err := s.apnsClient.Push(notification)
		if err != nil {
			slog.Warn("Live Activity APNs push failed",
				"event_id", eventID, "token_id", t.ID, "error", err)
			continue
		}
		if !res.Sent() {
			slog.Warn("Live Activity APNs rejected",
				"event_id", eventID, "token_id", t.ID,
				"reason", res.Reason, "status", res.StatusCode)
			// Reasons that mean the token is dead — drop it.
			if res.Reason == "BadDeviceToken" || res.Reason == "Unregistered" || res.Reason == "ExpiredToken" {
				if delErr := s.tokenRepo.DeleteByToken(ctx, t.PushToken); delErr != nil {
					slog.Warn("Failed to delete dead live activity token",
						"token_id", t.ID, "error", delErr)
				}
			}
		}
	}
	return nil
}

// buildLiveActivityPayload constructs the JSON payload APNs expects for a
// Live Activity push. Documented at:
// https://developer.apple.com/documentation/activitykit/updating-and-ending-your-live-activity-with-activitykit-push-notifications
func buildLiveActivityPayload(event LiveActivityEvent, state LiveActivityContentState, dismissAt *time.Time) ([]byte, error) {
	aps := map[string]interface{}{
		"timestamp":     time.Now().Unix(),
		"event":         string(event),
		"content-state": state,
	}
	if event == LiveActivityEventEnd && dismissAt != nil {
		aps["dismissal-date"] = dismissAt.Unix()
	}
	wrapper := map[string]interface{}{"aps": aps}
	return json.Marshal(wrapper)
}

// DeriveContentStateFromStatus builds a content state for a status transition,
// matching the iOS LiveActivityManager.updateEventActivity logic.
func DeriveContentStateFromStatus(status string, startTime time.Time) LiveActivityContentState {
	label := statusLabelFor(status)
	canonical := canonicalLiveStatus(status)
	elapsed := int(time.Since(startTime).Minutes())
	if elapsed < 0 {
		elapsed = 0
	}
	return LiveActivityContentState{
		Status:         canonical,
		StartTime:      startTime,
		ElapsedMinutes: elapsed,
		StatusLabel:    label,
	}
}

func canonicalLiveStatus(status string) string {
	switch status {
	case "confirmed":
		return "setup"
	case "completed":
		return "completed"
	case "cancelled":
		return "completed"
	default:
		return "in_progress"
	}
}

func statusLabelFor(status string) string {
	switch canonicalLiveStatus(status) {
	case "setup":
		return "Preparando"
	case "in_progress":
		return "En curso"
	case "completed":
		return "Finalizado"
	default:
		return status
	}
}
