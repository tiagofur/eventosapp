package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestCORS(t *testing.T) {
	tests := []struct {
		name            string
		origin          string
		method          string
		wantStatus      int
		wantAllowOrigin string
		wantNextCalled  bool
	}{
		{
			name:            "GivenAllowedOrigin_WhenGet_ThenSetAllowOrigin",
			origin:          "http://allowed.com",
			method:          http.MethodGet,
			wantStatus:      http.StatusAccepted,
			wantAllowOrigin: "http://allowed.com",
			wantNextCalled:  true,
		},
		{
			name:            "GivenDisallowedOrigin_WhenGet_ThenDoNotSetAllowOrigin",
			origin:          "http://blocked.com",
			method:          http.MethodGet,
			wantStatus:      http.StatusAccepted,
			wantAllowOrigin: "",
			wantNextCalled:  true,
		},
		{
			name:            "GivenOptionsRequest_WhenRequest_ThenReturnNoContent",
			origin:          "http://allowed.com",
			method:          http.MethodOptions,
			wantStatus:      http.StatusNoContent,
			wantAllowOrigin: "http://allowed.com",
			wantNextCalled:  false,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			nextCalled := false
			next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				nextCalled = true
				w.WriteHeader(http.StatusAccepted)
			})
			handler := CORS([]string{"http://allowed.com"})(next)

			req := httptest.NewRequest(tc.method, "/api/test", nil)
			req.Header.Set("Origin", tc.origin)
			rr := httptest.NewRecorder()
			handler.ServeHTTP(rr, req)

			if rr.Code != tc.wantStatus {
				t.Fatalf("status = %d, want %d", rr.Code, tc.wantStatus)
			}
			if got := rr.Header().Get("Access-Control-Allow-Origin"); got != tc.wantAllowOrigin {
				t.Fatalf("Access-Control-Allow-Origin = %q, want %q", got, tc.wantAllowOrigin)
			}
			if got := rr.Header().Get("Access-Control-Allow-Methods"); got == "" {
				t.Fatalf("Access-Control-Allow-Methods should be set")
			}
			if nextCalled != tc.wantNextCalled {
				t.Fatalf("nextCalled = %v, want %v", nextCalled, tc.wantNextCalled)
			}
		})
	}
}
