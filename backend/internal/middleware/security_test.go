package middleware

import (
	"crypto/tls"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestSecurityHeaders(t *testing.T) {
	handler := SecurityHeaders(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("ok"))
	}))

	req := httptest.NewRequest("GET", "/test", nil)
	rr := httptest.NewRecorder()

	handler.ServeHTTP(rr, req)

	// Check standard headers
	headers := map[string]string{
		"X-Content-Type-Options": "nosniff",
		"X-Frame-Options":        "DENY",
		"X-XSS-Protection":       "1; mode=block",
		"Referrer-Policy":        "strict-origin-when-cross-origin",
	}

	for k, v := range headers {
		if val := rr.Header().Get(k); val != v {
			t.Errorf("expected header %q to be %q, got %q", k, v, val)
		}
	}

	// Check CSP contains some expected parts
	csp := rr.Header().Get("Content-Security-Policy")
	if !strings.Contains(csp, "default-src 'self'") {
		t.Errorf("CSP missing default-src, got: %s", csp)
	}

	// Check HTTP behavior for strict transport security
	// non-https request without X-Forwarded-Proto
	if hsts := rr.Header().Get("Strict-Transport-Security"); hsts != "" {
		t.Errorf("expected empty HSTS header for standard HTTP req, got %q", hsts)
	}
}

func TestSecurityHeadersHTTPS(t *testing.T) {
	handler := SecurityHeaders(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	// TLS request
	req := httptest.NewRequest("GET", "/test", nil)
	req.TLS = &tls.ConnectionState{}
	rr := httptest.NewRecorder()

	handler.ServeHTTP(rr, req)

	if hsts := rr.Header().Get("Strict-Transport-Security"); hsts != "max-age=31536000; includeSubDomains" {
		t.Errorf("expected HSTS header for TLS req, got %q", hsts)
	}

	// X-Forwarded-Proto request
	req = httptest.NewRequest("GET", "/test", nil)
	req.Header.Set("X-Forwarded-Proto", "https")
	rr = httptest.NewRecorder()

	handler.ServeHTTP(rr, req)

	if hsts := rr.Header().Get("Strict-Transport-Security"); hsts != "max-age=31536000; includeSubDomains" {
		t.Errorf("expected HSTS header for Forwarded-Proto req, got %q", hsts)
	}
}
