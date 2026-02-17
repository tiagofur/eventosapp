package handlers

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
)

func TestCRUDHandlerValidationPaths(t *testing.T) {
	h := &CRUDHandler{}

	tests := []struct {
		name       string
		method     string
		path       string
		body       string
		idParam    string
		call       func(*CRUDHandler, http.ResponseWriter, *http.Request)
		wantStatus int
		wantBody   string
	}{
		{
			name:       "GivenInvalidClientID_WhenGetClient_ThenBadRequest",
			method:     http.MethodGet,
			path:       "/api/clients/bad",
			idParam:    "bad",
			call:       (*CRUDHandler).GetClient,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid client ID",
		},
		{
			name:       "GivenInvalidClientID_WhenUpdateClient_ThenBadRequest",
			method:     http.MethodPut,
			path:       "/api/clients/bad",
			idParam:    "bad",
			body:       `{}`,
			call:       (*CRUDHandler).UpdateClient,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid client ID",
		},
		{
			name:       "GivenInvalidClientBody_WhenCreateClient_ThenBadRequest",
			method:     http.MethodPost,
			path:       "/api/clients",
			body:       `{"name":}`,
			call:       (*CRUDHandler).CreateClient,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid request body",
		},
		{
			name:       "GivenInvalidEventID_WhenGetEvent_ThenBadRequest",
			method:     http.MethodGet,
			path:       "/api/events/bad",
			idParam:    "bad",
			call:       (*CRUDHandler).GetEvent,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid event ID",
		},
		{
			name:       "GivenInvalidEventID_WhenUpdateEvent_ThenBadRequest",
			method:     http.MethodPut,
			path:       "/api/events/bad",
			idParam:    "bad",
			body:       `{}`,
			call:       (*CRUDHandler).UpdateEvent,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid event ID",
		},
		{
			name:       "GivenInvalidEventID_WhenUpdateEventItems_ThenBadRequest",
			method:     http.MethodPut,
			path:       "/api/events/bad/items",
			idParam:    "bad",
			body:       `{}`,
			call:       (*CRUDHandler).UpdateEventItems,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid event ID",
		},
		{
			name:       "GivenInvalidProductID_WhenGetProduct_ThenBadRequest",
			method:     http.MethodGet,
			path:       "/api/products/bad",
			idParam:    "bad",
			call:       (*CRUDHandler).GetProduct,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid product ID",
		},
		{
			name:       "GivenInvalidProductBody_WhenCreateProduct_ThenBadRequest",
			method:     http.MethodPost,
			path:       "/api/products",
			body:       `{"name":}`,
			call:       (*CRUDHandler).CreateProduct,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid request body",
		},
		{
			name:       "GivenInvalidInventoryID_WhenGetInventory_ThenBadRequest",
			method:     http.MethodGet,
			path:       "/api/inventory/bad",
			idParam:    "bad",
			call:       (*CRUDHandler).GetInventoryItem,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid inventory ID",
		},
		{
			name:       "GivenInvalidInventoryBody_WhenCreateInventory_ThenBadRequest",
			method:     http.MethodPost,
			path:       "/api/inventory",
			body:       `{"name":}`,
			call:       (*CRUDHandler).CreateInventoryItem,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid request body",
		},
		{
			name:       "GivenInvalidPaymentID_WhenUpdatePayment_ThenBadRequest",
			method:     http.MethodPut,
			path:       "/api/payments/bad",
			idParam:    "bad",
			body:       `{}`,
			call:       (*CRUDHandler).UpdatePayment,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid payment ID",
		},
		{
			name:       "GivenInvalidPaymentID_WhenDeletePayment_ThenBadRequest",
			method:     http.MethodDelete,
			path:       "/api/payments/bad",
			idParam:    "bad",
			call:       (*CRUDHandler).DeletePayment,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid payment ID",
		},
		{
			name:       "GivenInvalidPaymentBody_WhenCreatePayment_ThenBadRequest",
			method:     http.MethodPost,
			path:       "/api/payments",
			body:       `{"event_id":}`,
			call:       (*CRUDHandler).CreatePayment,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid request body",
		},
		{
			name:       "GivenInvalidEventIDFilter_WhenListPayments_ThenBadRequest",
			method:     http.MethodGet,
			path:       "/api/payments?event_id=bad",
			call:       (*CRUDHandler).ListPayments,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid event_id",
		},
		{
			name:       "GivenInvalidClientIDFilter_WhenListEvents_ThenBadRequest",
			method:     http.MethodGet,
			path:       "/api/events?client_id=bad",
			call:       (*CRUDHandler).ListEvents,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid client_id",
		},
		{
			name:       "GivenInvalidStartDateFilter_WhenListEvents_ThenBadRequest",
			method:     http.MethodGet,
			path:       "/api/events?start=bad-date&end=2026-12-31",
			call:       (*CRUDHandler).ListEvents,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid start date",
		},
		{
			name:       "GivenInvalidEndDateFilter_WhenListEvents_ThenBadRequest",
			method:     http.MethodGet,
			path:       "/api/events?start=2026-12-01&end=bad-date",
			call:       (*CRUDHandler).ListEvents,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid end date",
		},
		{
			name:       "GivenInvalidEventIDsFilter_WhenListPayments_ThenBadRequest",
			method:     http.MethodGet,
			path:       "/api/payments?event_ids=bad",
			call:       (*CRUDHandler).ListPayments,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid event_ids",
		},
		{
			name:       "GivenEmptyEventIDsFilter_WhenListPayments_ThenBadRequest",
			method:     http.MethodGet,
			path:       "/api/payments?event_ids=,,",
			call:       (*CRUDHandler).ListPayments,
			wantStatus: http.StatusBadRequest,
			wantBody:   "Invalid event_ids",
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			req := httptest.NewRequest(tc.method, tc.path, strings.NewReader(tc.body))
			if tc.idParam != "" {
				req = withURLParam(req, "id", tc.idParam)
			}
			rr := httptest.NewRecorder()

			tc.call(h, rr, req)

			if rr.Code != tc.wantStatus {
				t.Fatalf("status = %d, want %d", rr.Code, tc.wantStatus)
			}
			if !strings.Contains(rr.Body.String(), tc.wantBody) {
				t.Fatalf("body = %q, expected to contain %q", rr.Body.String(), tc.wantBody)
			}
		})
	}
}

func TestListPaymentsNoFiltersReturnsEmptyArray(t *testing.T) {
	h := &CRUDHandler{}
	req := httptest.NewRequest(http.MethodGet, "/api/payments", nil)
	rr := httptest.NewRecorder()

	h.ListPayments(rr, req)

	if rr.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", rr.Code, http.StatusOK)
	}
	if !strings.Contains(rr.Body.String(), "[]") {
		t.Fatalf("body = %q, expected empty array", rr.Body.String())
	}
}

func TestSplitCSV(t *testing.T) {
	got := splitCSV(" a, ,b,, c ")
	if len(got) != 3 || got[0] != "a" || got[1] != "b" || got[2] != "c" {
		t.Fatalf("splitCSV() = %#v, want [a b c]", got)
	}
}

func TestSplitAndTrim(t *testing.T) {
	parts := split("x,y", ",")
	if len(parts) != 2 || parts[0] != "x" || parts[1] != "y" {
		t.Fatalf("split() returned unexpected parts: %#v", parts)
	}
	if got := trim("  hello  "); got != "hello" {
		t.Fatalf("trim() = %q, want %q", got, "hello")
	}
}

func FuzzSplitCSV_NoEmptyElements(f *testing.F) {
	f.Add("a,b,c")
	f.Add(" a, ,b,, c ")
	f.Add("")
	f.Add(",,")
	f.Add("uno, dos, tres")

	f.Fuzz(func(t *testing.T, input string) {
		got := splitCSV(input)
		for _, part := range got {
			if part == "" {
				t.Fatalf("splitCSV() returned empty element for input %q", input)
			}
			if part != strings.TrimSpace(part) {
				t.Fatalf("splitCSV() returned untrimmed element %q for input %q", part, input)
			}
		}
	})
}

func FuzzTrim_Idempotent(f *testing.F) {
	f.Add(" hello ")
	f.Add("\tvalue\n")
	f.Add("")
	f.Add("no-spaces")

	f.Fuzz(func(t *testing.T, input string) {
		once := trim(input)
		twice := trim(once)
		if once != twice {
			t.Fatalf("trim() should be idempotent: once=%q twice=%q input=%q", once, twice, input)
		}
	})
}

func TestNormalizeDateParam(t *testing.T) {
	got, err := normalizeDateParam("2026-02-01T06:00:00.000Z")
	if err != nil || got != "2026-02-01" {
		t.Fatalf("normalizeDateParam(rfc3339) = %q, %v", got, err)
	}

	got, err = normalizeDateParam("2026-03-01")
	if err != nil || got != "2026-03-01" {
		t.Fatalf("normalizeDateParam(date) = %q, %v", got, err)
	}

	if _, err = normalizeDateParam("invalid"); err == nil {
		t.Fatalf("normalizeDateParam() expected error for invalid input")
	}
}

func TestUpdateHandlersInvalidBodyWithValidIDs(t *testing.T) {
	h := &CRUDHandler{}
	validID := uuid.New().String()

	req := withURLParam(httptest.NewRequest(http.MethodPut, "/api/events/"+validID+"/items", strings.NewReader(`{"products":}`)), "id", validID)
	rr := httptest.NewRecorder()
	h.UpdateEventItems(rr, req)
	if rr.Code != http.StatusBadRequest {
		t.Fatalf("UpdateEventItems status = %d, want %d", rr.Code, http.StatusBadRequest)
	}

	req = withURLParam(httptest.NewRequest(http.MethodPut, "/api/products/"+validID+"/ingredients", strings.NewReader(`{"ingredients":}`)), "id", validID)
	rr = httptest.NewRecorder()
	h.UpdateProductIngredients(rr, req)
	if rr.Code != http.StatusBadRequest {
		t.Fatalf("UpdateProductIngredients status = %d, want %d", rr.Code, http.StatusBadRequest)
	}
}

func withURLParam(req *http.Request, key, value string) *http.Request {
	routeCtx := chi.NewRouteContext()
	routeCtx.URLParams.Add(key, value)
	ctx := context.WithValue(req.Context(), chi.RouteCtxKey, routeCtx)
	return req.WithContext(ctx)
}
