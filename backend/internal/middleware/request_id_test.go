package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/google/uuid"
)

func TestRequestID_GivenNoExistingHeader_WhenRequest_ThenGeneratesUUID(t *testing.T) {
	var capturedID string
	handler := RequestID(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		capturedID = GetRequestID(r.Context())
		w.WriteHeader(http.StatusOK)
	}))

	req := httptest.NewRequest(http.MethodGet, "/test", nil)
	rr := httptest.NewRecorder()
	handler.ServeHTTP(rr, req)

	// Response header should contain the ID
	headerID := rr.Header().Get("X-Request-ID")
	if headerID == "" {
		t.Fatal("X-Request-ID response header should not be empty")
	}

	// Should be a valid UUID
	if _, err := uuid.Parse(headerID); err != nil {
		t.Fatalf("X-Request-ID = %q, not a valid UUID: %v", headerID, err)
	}

	// Context should have the same ID
	if capturedID != headerID {
		t.Fatalf("context ID = %q, header ID = %q, should match", capturedID, headerID)
	}
}

func TestRequestID_GivenExistingHeader_WhenRequest_ThenPreservesIt(t *testing.T) {
	existingID := "my-custom-request-id-12345"
	var capturedID string

	handler := RequestID(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		capturedID = GetRequestID(r.Context())
		w.WriteHeader(http.StatusOK)
	}))

	req := httptest.NewRequest(http.MethodGet, "/test", nil)
	req.Header.Set("X-Request-ID", existingID)
	rr := httptest.NewRecorder()
	handler.ServeHTTP(rr, req)

	headerID := rr.Header().Get("X-Request-ID")
	if headerID != existingID {
		t.Fatalf("X-Request-ID = %q, want %q (preserved)", headerID, existingID)
	}

	if capturedID != existingID {
		t.Fatalf("context ID = %q, want %q", capturedID, existingID)
	}
}

func TestGetRequestID_GivenNoContextValue_ThenReturnsEmpty(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	if got := GetRequestID(req.Context()); got != "" {
		t.Fatalf("GetRequestID() = %q, want empty string", got)
	}
}
