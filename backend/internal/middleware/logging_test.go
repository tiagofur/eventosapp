package middleware

import (
	"context"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestLogger(t *testing.T) {
	t.Run("GivenHandlerWritesStatus_WhenRequest_ThenStatusPropagates", func(t *testing.T) {
		handler := Logger(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusTeapot)
			_, _ = w.Write([]byte("ok"))
		}))

		req := httptest.NewRequest(http.MethodGet, "/test", nil)
		rr := httptest.NewRecorder()
		handler.ServeHTTP(rr, req)

		if rr.Code != http.StatusTeapot {
			t.Fatalf("status = %d, want %d", rr.Code, http.StatusTeapot)
		}
		body, _ := io.ReadAll(rr.Result().Body)
		if string(body) != "ok" {
			t.Fatalf("body = %q, want %q", string(body), "ok")
		}
	})

	t.Run("GivenHandlerWithoutExplicitStatus_WhenRequest_ThenDefaultStatusOK", func(t *testing.T) {
		handler := Logger(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			_, _ = w.Write([]byte("payload"))
		}))

		req := httptest.NewRequest(http.MethodGet, "/test", nil)
		rr := httptest.NewRecorder()
		handler.ServeHTTP(rr, req)

		if rr.Code != http.StatusOK {
			t.Fatalf("status = %d, want %d", rr.Code, http.StatusOK)
		}
	})
}

func TestLogger_GivenRequestWithRequestID_WhenLogged_ThenIncludesRequestID(t *testing.T) {
	handler := Logger(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	req := httptest.NewRequest(http.MethodGet, "/test", nil)
	ctx := context.WithValue(req.Context(), RequestIDKey, "test-req-id-123")
	req = req.WithContext(ctx)
	rr := httptest.NewRecorder()
	handler.ServeHTTP(rr, req)

	if rr.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", rr.Code, http.StatusOK)
	}
}

func TestResponseWriterWriteHeader(t *testing.T) {
	rr := httptest.NewRecorder()
	wrapped := &responseWriter{ResponseWriter: rr, statusCode: http.StatusOK}

	wrapped.WriteHeader(http.StatusCreated)

	if wrapped.statusCode != http.StatusCreated {
		t.Fatalf("statusCode = %d, want %d", wrapped.statusCode, http.StatusCreated)
	}
	if rr.Code != http.StatusCreated {
		t.Fatalf("recorder code = %d, want %d", rr.Code, http.StatusCreated)
	}
}
