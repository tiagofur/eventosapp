package handlers

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"github.com/tiagofur/solennix-backend/internal/middleware"
	"github.com/tiagofur/solennix-backend/internal/models"
)

// MockDeviceRepo implements DeviceRepository for testing
type MockDeviceRepo struct {
	mock.Mock
}

func (m *MockDeviceRepo) Register(ctx context.Context, userID uuid.UUID, token, platform string) (*models.DeviceToken, error) {
	args := m.Called(ctx, userID, token, platform)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*models.DeviceToken), args.Error(1)
}

func (m *MockDeviceRepo) Unregister(ctx context.Context, userID uuid.UUID, token string) error {
	args := m.Called(ctx, userID, token)
	return args.Error(0)
}

func (m *MockDeviceRepo) GetByUserID(ctx context.Context, userID uuid.UUID) ([]models.DeviceToken, error) {
	args := m.Called(ctx, userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]models.DeviceToken), args.Error(1)
}

func (m *MockDeviceRepo) UnregisterAllForUser(ctx context.Context, userID uuid.UUID) error {
	args := m.Called(ctx, userID)
	return args.Error(0)
}

func makeDeviceReq(method, path, body string, userID uuid.UUID) *http.Request {
	req := httptest.NewRequest(method, path, strings.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	return req.WithContext(context.WithValue(req.Context(), middleware.UserIDKey, userID))
}

func TestDeviceHandler_RegisterDevice(t *testing.T) {
	userID := uuid.New()

	t.Run("Success_iOS", func(t *testing.T) {
		repo := new(MockDeviceRepo)
		h := NewDeviceHandler(repo)
		device := &models.DeviceToken{ID: uuid.New(), UserID: userID, Token: "fcm-token-123", Platform: "ios"}
		repo.On("Register", mock.Anything, userID, "fcm-token-123", "ios").Return(device, nil)

		req := makeDeviceReq(http.MethodPost, "/api/devices/register", `{"token":"fcm-token-123","platform":"ios"}`, userID)
		rr := httptest.NewRecorder()
		h.RegisterDevice(rr, req)

		assert.Equal(t, http.StatusOK, rr.Code)
		assert.Contains(t, rr.Body.String(), "fcm-token-123")
		repo.AssertExpectations(t)
	})

	t.Run("Success_Android", func(t *testing.T) {
		repo := new(MockDeviceRepo)
		h := NewDeviceHandler(repo)
		device := &models.DeviceToken{ID: uuid.New(), UserID: userID, Token: "android-token", Platform: "android"}
		repo.On("Register", mock.Anything, userID, "android-token", "android").Return(device, nil)

		req := makeDeviceReq(http.MethodPost, "/api/devices/register", `{"token":"android-token","platform":"android"}`, userID)
		rr := httptest.NewRecorder()
		h.RegisterDevice(rr, req)

		assert.Equal(t, http.StatusOK, rr.Code)
		repo.AssertExpectations(t)
	})

	t.Run("Success_Web", func(t *testing.T) {
		repo := new(MockDeviceRepo)
		h := NewDeviceHandler(repo)
		device := &models.DeviceToken{ID: uuid.New(), UserID: userID, Token: "web-push-token", Platform: "web"}
		repo.On("Register", mock.Anything, userID, "web-push-token", "web").Return(device, nil)

		req := makeDeviceReq(http.MethodPost, "/api/devices/register", `{"token":"web-push-token","platform":"web"}`, userID)
		rr := httptest.NewRecorder()
		h.RegisterDevice(rr, req)

		assert.Equal(t, http.StatusOK, rr.Code)
		repo.AssertExpectations(t)
	})

	t.Run("InvalidJSON_Returns400", func(t *testing.T) {
		h := NewDeviceHandler(new(MockDeviceRepo))
		req := makeDeviceReq(http.MethodPost, "/api/devices/register", `{invalid`, userID)
		rr := httptest.NewRecorder()
		h.RegisterDevice(rr, req)

		assert.Equal(t, http.StatusBadRequest, rr.Code)
		assert.Contains(t, rr.Body.String(), "Invalid request body")
	})

	t.Run("MissingToken_Returns400", func(t *testing.T) {
		h := NewDeviceHandler(new(MockDeviceRepo))
		req := makeDeviceReq(http.MethodPost, "/api/devices/register", `{"platform":"ios"}`, userID)
		rr := httptest.NewRecorder()
		h.RegisterDevice(rr, req)

		assert.Equal(t, http.StatusBadRequest, rr.Code)
		assert.Contains(t, rr.Body.String(), "token is required")
	})

	t.Run("EmptyToken_Returns400", func(t *testing.T) {
		h := NewDeviceHandler(new(MockDeviceRepo))
		req := makeDeviceReq(http.MethodPost, "/api/devices/register", `{"token":"","platform":"ios"}`, userID)
		rr := httptest.NewRecorder()
		h.RegisterDevice(rr, req)

		assert.Equal(t, http.StatusBadRequest, rr.Code)
		assert.Contains(t, rr.Body.String(), "token is required")
	})

	t.Run("InvalidPlatform_Returns400", func(t *testing.T) {
		h := NewDeviceHandler(new(MockDeviceRepo))
		req := makeDeviceReq(http.MethodPost, "/api/devices/register", `{"token":"tok","platform":"windows"}`, userID)
		rr := httptest.NewRecorder()
		h.RegisterDevice(rr, req)

		assert.Equal(t, http.StatusBadRequest, rr.Code)
		assert.Contains(t, rr.Body.String(), "platform must be")
	})

	t.Run("EmptyPlatform_Returns400", func(t *testing.T) {
		h := NewDeviceHandler(new(MockDeviceRepo))
		req := makeDeviceReq(http.MethodPost, "/api/devices/register", `{"token":"tok","platform":""}`, userID)
		rr := httptest.NewRecorder()
		h.RegisterDevice(rr, req)

		assert.Equal(t, http.StatusBadRequest, rr.Code)
		assert.Contains(t, rr.Body.String(), "platform must be")
	})

	t.Run("RepoError_Returns500", func(t *testing.T) {
		repo := new(MockDeviceRepo)
		h := NewDeviceHandler(repo)
		repo.On("Register", mock.Anything, userID, "tok", "ios").Return(nil, assert.AnError)

		req := makeDeviceReq(http.MethodPost, "/api/devices/register", `{"token":"tok","platform":"ios"}`, userID)
		rr := httptest.NewRecorder()
		h.RegisterDevice(rr, req)

		assert.Equal(t, http.StatusInternalServerError, rr.Code)
		assert.Contains(t, rr.Body.String(), "Failed to register device")
		repo.AssertExpectations(t)
	})
}

func TestDeviceHandler_UnregisterDevice(t *testing.T) {
	userID := uuid.New()

	t.Run("Success", func(t *testing.T) {
		repo := new(MockDeviceRepo)
		h := NewDeviceHandler(repo)
		repo.On("Unregister", mock.Anything, userID, "fcm-token-123").Return(nil)

		req := makeDeviceReq(http.MethodPost, "/api/devices/unregister", `{"token":"fcm-token-123"}`, userID)
		rr := httptest.NewRecorder()
		h.UnregisterDevice(rr, req)

		assert.Equal(t, http.StatusOK, rr.Code)
		assert.Contains(t, rr.Body.String(), "ok")
		repo.AssertExpectations(t)
	})

	t.Run("InvalidJSON_Returns400", func(t *testing.T) {
		h := NewDeviceHandler(new(MockDeviceRepo))
		req := makeDeviceReq(http.MethodPost, "/api/devices/unregister", `{bad`, userID)
		rr := httptest.NewRecorder()
		h.UnregisterDevice(rr, req)

		assert.Equal(t, http.StatusBadRequest, rr.Code)
		assert.Contains(t, rr.Body.String(), "Invalid request body")
	})

	t.Run("MissingToken_Returns400", func(t *testing.T) {
		h := NewDeviceHandler(new(MockDeviceRepo))
		req := makeDeviceReq(http.MethodPost, "/api/devices/unregister", `{}`, userID)
		rr := httptest.NewRecorder()
		h.UnregisterDevice(rr, req)

		assert.Equal(t, http.StatusBadRequest, rr.Code)
		assert.Contains(t, rr.Body.String(), "token is required")
	})

	t.Run("RepoError_StillReturnsOK", func(t *testing.T) {
		repo := new(MockDeviceRepo)
		h := NewDeviceHandler(repo)
		repo.On("Unregister", mock.Anything, userID, "unknown-token").Return(assert.AnError)

		req := makeDeviceReq(http.MethodPost, "/api/devices/unregister", `{"token":"unknown-token"}`, userID)
		rr := httptest.NewRecorder()
		h.UnregisterDevice(rr, req)

		// Handler silently succeeds even on error (prevents enumeration)
		assert.Equal(t, http.StatusOK, rr.Code)
		repo.AssertExpectations(t)
	})
}
