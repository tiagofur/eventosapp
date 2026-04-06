package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestAPIVersion(t *testing.T) {
	handler := APIVersion("v1")(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("ok"))
	}))

	req := httptest.NewRequest("GET", "/test", nil)
	rr := httptest.NewRecorder()

	handler.ServeHTTP(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("expected status 200, got %d", rr.Code)
	}

	if v := rr.Header().Get("X-API-Version"); v != "v1" {
		t.Errorf("expected X-API-Version header %q, got %q", "v1", v)
	}
}

func TestAPIVersionDifferentVersions(t *testing.T) {
	tests := []struct {
		version string
	}{
		{"v1"},
		{"v2"},
		{"v3-beta"},
	}

	for _, tt := range tests {
		t.Run(tt.version, func(t *testing.T) {
			handler := APIVersion(tt.version)(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				w.WriteHeader(http.StatusOK)
			}))

			req := httptest.NewRequest("GET", "/test", nil)
			rr := httptest.NewRecorder()

			handler.ServeHTTP(rr, req)

			if v := rr.Header().Get("X-API-Version"); v != tt.version {
				t.Errorf("expected X-API-Version %q, got %q", tt.version, v)
			}
		})
	}
}
