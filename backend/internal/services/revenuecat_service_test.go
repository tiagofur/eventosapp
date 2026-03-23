package services

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

// newTestRevenueCatService creates a RevenueCatService that points at a test
// server instead of the real RevenueCat API.
func newTestRevenueCatService(apiKey string, serverURL string) *RevenueCatService {
	svc := NewRevenueCatService(apiKey)
	svc.baseURL = serverURL
	return svc
}

func TestNewRevenueCatService(t *testing.T) {
	svc := NewRevenueCatService("sk_test_key")
	if svc == nil {
		t.Fatal("NewRevenueCatService() returned nil")
	}
	if svc.apiKey != "sk_test_key" {
		t.Errorf("apiKey = %q, want %q", svc.apiKey, "sk_test_key")
	}
	if svc.httpClient == nil {
		t.Error("httpClient should not be nil")
	}
	if svc.baseURL != "https://api.revenuecat.com/v1" {
		t.Errorf("baseURL = %q, want default RevenueCat URL", svc.baseURL)
	}
}

func TestIsConfigured_WithAPIKey(t *testing.T) {
	svc := NewRevenueCatService("sk_test_key")
	if !svc.IsConfigured() {
		t.Error("IsConfigured() should return true when API key is set")
	}
}

func TestIsConfigured_WithoutAPIKey(t *testing.T) {
	svc := NewRevenueCatService("")
	if svc.IsConfigured() {
		t.Error("IsConfigured() should return false when API key is empty")
	}
}

func TestGrantPromotionalEntitlement_NotConfigured(t *testing.T) {
	svc := NewRevenueCatService("") // not configured

	err := svc.GrantPromotionalEntitlement(context.Background(), "user123", "pro", "monthly")
	if err != nil {
		t.Fatalf("GrantPromotionalEntitlement() should be a no-op when not configured, got error: %v", err)
	}
}

func TestGrantPromotionalEntitlement_Success(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Verify request method and path
		if r.Method != http.MethodPost {
			t.Errorf("expected POST, got %s", r.Method)
		}
		if !strings.Contains(r.URL.Path, "/subscribers/user123/entitlements/pro/promotional") {
			t.Errorf("unexpected path: %s", r.URL.Path)
		}

		// Verify headers
		authHeader := r.Header.Get("Authorization")
		if authHeader != "Bearer sk_test_key" {
			t.Errorf("Authorization = %q, want %q", authHeader, "Bearer sk_test_key")
		}
		if r.Header.Get("Content-Type") != "application/json" {
			t.Errorf("Content-Type = %q, want %q", r.Header.Get("Content-Type"), "application/json")
		}
		if r.Header.Get("X-Platform") != "stripe" {
			t.Errorf("X-Platform = %q, want %q", r.Header.Get("X-Platform"), "stripe")
		}

		// Verify body
		body, _ := io.ReadAll(r.Body)
		var payload map[string]string
		if err := json.Unmarshal(body, &payload); err != nil {
			t.Errorf("failed to unmarshal request body: %v", err)
		}
		if payload["duration"] != "monthly" {
			t.Errorf("duration = %q, want %q", payload["duration"], "monthly")
		}

		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"subscriber": {}}`))
	}))
	defer server.Close()

	svc := newTestRevenueCatService("sk_test_key", server.URL)

	err := svc.GrantPromotionalEntitlement(context.Background(), "user123", "pro", "monthly")
	if err != nil {
		t.Fatalf("GrantPromotionalEntitlement() error = %v", err)
	}
}

func TestGrantPromotionalEntitlement_HTTPError(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(`{"message": "internal error"}`))
	}))
	defer server.Close()

	svc := newTestRevenueCatService("sk_test_key", server.URL)

	err := svc.GrantPromotionalEntitlement(context.Background(), "user123", "pro", "monthly")
	if err == nil {
		t.Fatal("GrantPromotionalEntitlement() expected error for HTTP 500")
	}
	if !strings.Contains(err.Error(), "status 500") {
		t.Errorf("error should mention status 500, got: %v", err)
	}
}

func TestGrantPromotionalEntitlement_NetworkError(t *testing.T) {
	// Point to an unreachable server
	svc := newTestRevenueCatService("sk_test_key", "http://127.0.0.1:1")

	err := svc.GrantPromotionalEntitlement(context.Background(), "user123", "pro", "monthly")
	if err == nil {
		t.Fatal("GrantPromotionalEntitlement() expected error for unreachable server")
	}
	if !strings.Contains(err.Error(), "grant entitlement request") {
		t.Errorf("error should wrap with 'grant entitlement request', got: %v", err)
	}
}

func TestRevokePromotionalEntitlement_NotConfigured(t *testing.T) {
	svc := NewRevenueCatService("") // not configured

	err := svc.RevokePromotionalEntitlement(context.Background(), "user123", "pro")
	if err != nil {
		t.Fatalf("RevokePromotionalEntitlement() should be a no-op when not configured, got error: %v", err)
	}
}

func TestRevokePromotionalEntitlement_Success(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Verify request method and path
		if r.Method != http.MethodPost {
			t.Errorf("expected POST, got %s", r.Method)
		}
		if !strings.Contains(r.URL.Path, "/subscribers/user123/entitlements/pro/revoke_promotionals") {
			t.Errorf("unexpected path: %s", r.URL.Path)
		}

		// Verify headers
		authHeader := r.Header.Get("Authorization")
		if authHeader != "Bearer sk_test_key" {
			t.Errorf("Authorization = %q, want %q", authHeader, "Bearer sk_test_key")
		}
		if r.Header.Get("Content-Type") != "application/json" {
			t.Errorf("Content-Type = %q, want %q", r.Header.Get("Content-Type"), "application/json")
		}

		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"subscriber": {}}`))
	}))
	defer server.Close()

	svc := newTestRevenueCatService("sk_test_key", server.URL)

	err := svc.RevokePromotionalEntitlement(context.Background(), "user123", "pro")
	if err != nil {
		t.Fatalf("RevokePromotionalEntitlement() error = %v", err)
	}
}

func TestRevokePromotionalEntitlement_HTTPError(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusForbidden)
		w.Write([]byte(`{"message": "forbidden"}`))
	}))
	defer server.Close()

	svc := newTestRevenueCatService("sk_test_key", server.URL)

	err := svc.RevokePromotionalEntitlement(context.Background(), "user123", "pro")
	if err == nil {
		t.Fatal("RevokePromotionalEntitlement() expected error for HTTP 403")
	}
	if !strings.Contains(err.Error(), "status 403") {
		t.Errorf("error should mention status 403, got: %v", err)
	}
}

func TestRevokePromotionalEntitlement_NetworkError(t *testing.T) {
	// Point to an unreachable server
	svc := newTestRevenueCatService("sk_test_key", "http://127.0.0.1:1")

	err := svc.RevokePromotionalEntitlement(context.Background(), "user123", "pro")
	if err == nil {
		t.Fatal("RevokePromotionalEntitlement() expected error for unreachable server")
	}
	if !strings.Contains(err.Error(), "revoke entitlement request") {
		t.Errorf("error should wrap with 'revoke entitlement request', got: %v", err)
	}
}

func TestGrantPromotionalEntitlement_HTTP4xxError(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusNotFound)
		w.Write([]byte(`{"message": "subscriber not found"}`))
	}))
	defer server.Close()

	svc := newTestRevenueCatService("sk_test_key", server.URL)

	err := svc.GrantPromotionalEntitlement(context.Background(), "unknown-user", "pro", "monthly")
	if err == nil {
		t.Fatal("GrantPromotionalEntitlement() expected error for HTTP 404")
	}
	if !strings.Contains(err.Error(), "status 404") {
		t.Errorf("error should mention status 404, got: %v", err)
	}
}
