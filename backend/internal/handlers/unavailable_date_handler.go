package handlers

import (
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/tiagofur/solennix-backend/internal/middleware"
	"github.com/tiagofur/solennix-backend/internal/models"
)

type UnavailableDateHandler struct {
	repo UnavailableDateRepository
}

func NewUnavailableDateHandler(repo UnavailableDateRepository) *UnavailableDateHandler {
	return &UnavailableDateHandler{repo: repo}
}

func (h *UnavailableDateHandler) GetUnavailableDates(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	startStr := r.URL.Query().Get("start")
	endStr := r.URL.Query().Get("end")

	if startStr == "" || endStr == "" {
		writeError(w, http.StatusBadRequest, "start and end dates are required")
		return
	}

	// Validate date formats
	if _, err := time.Parse("2006-01-02", startStr); err != nil {
		writeError(w, http.StatusBadRequest, "invalid start date format, expected YYYY-MM-DD")
		return
	}
	if _, err := time.Parse("2006-01-02", endStr); err != nil {
		writeError(w, http.StatusBadRequest, "invalid end date format, expected YYYY-MM-DD")
		return
	}

	dates, err := h.repo.GetByDateRange(r.Context(), userID, startStr, endStr)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to get unavailable dates")
		return
	}
	writeJSON(w, http.StatusOK, dates)
}

func (h *UnavailableDateHandler) CreateUnavailableDate(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var body struct {
		StartDate string `json:"start_date"`
		EndDate   string `json:"end_date"`
		Reason    string `json:"reason"`
	}
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	// Basic validation
	if body.StartDate == "" || body.EndDate == "" {
		writeError(w, http.StatusBadRequest, "start_date and end_date are required")
		return
	}

	start, err := time.Parse("2006-01-02", body.StartDate)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid start_date format, expected YYYY-MM-DD")
		return
	}
	end, err := time.Parse("2006-01-02", body.EndDate)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid end_date format, expected YYYY-MM-DD")
		return
	}

	if end.Before(start) {
		writeError(w, http.StatusBadRequest, "end_date must be after or equal to start_date")
		return
	}

	var reasonPtr *string
	if body.Reason != "" {
		reasonPtr = &body.Reason
	}

	ud := &models.UnavailableDate{
		UserID:    userID,
		StartDate: body.StartDate,
		EndDate:   body.EndDate,
		Reason:    reasonPtr,
	}

	if err := h.repo.Create(r.Context(), ud); err != nil {
		writeError(w, http.StatusInternalServerError, "failed to create unavailable date")
		return
	}

	writeJSON(w, http.StatusCreated, ud)
}

func (h *UnavailableDateHandler) DeleteUnavailableDate(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	idStr := chi.URLParam(r, "id")

	id, err := uuid.Parse(idStr)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	if err := h.repo.Delete(r.Context(), id, userID); err != nil {
		writeError(w, http.StatusNotFound, "unavailable date not found")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}
