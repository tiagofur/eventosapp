package handlers

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
)

// ---------------------------------------------------------------------------
// parsePaginationParams
// ---------------------------------------------------------------------------

func TestParsePaginationParams(t *testing.T) {
	allowedSorts := map[string]string{
		"name":       "name",
		"created_at": "created_at",
	}

	t.Run("GivenNoPageParam_WhenParsed_ThenReturnNil", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/items", nil)
		params := parsePaginationParams(req, allowedSorts, "name")
		assert.Nil(t, params)
	})

	t.Run("GivenPage1_WhenParsed_ThenReturnDefaults", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/items?page=1", nil)
		params := parsePaginationParams(req, allowedSorts, "name")

		assert.NotNil(t, params)
		assert.Equal(t, 1, params.Page)
		assert.Equal(t, 20, params.Limit)
		assert.Equal(t, "name", params.Sort)
		assert.Equal(t, "DESC", params.Order)
	})

	t.Run("GivenInvalidPage_WhenParsed_ThenDefaultToPage1", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/items?page=abc", nil)
		params := parsePaginationParams(req, allowedSorts, "name")

		assert.NotNil(t, params)
		assert.Equal(t, 1, params.Page)
	})

	t.Run("GivenNegativePage_WhenParsed_ThenDefaultToPage1", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/items?page=-3", nil)
		params := parsePaginationParams(req, allowedSorts, "name")

		assert.NotNil(t, params)
		assert.Equal(t, 1, params.Page)
	})

	t.Run("GivenCustomLimit_WhenParsed_ThenUseCustomLimit", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/items?page=1&limit=50", nil)
		params := parsePaginationParams(req, allowedSorts, "name")

		assert.Equal(t, 50, params.Limit)
	})

	t.Run("GivenInvalidLimit_WhenParsed_ThenUseDefault20", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/items?page=1&limit=abc", nil)
		params := parsePaginationParams(req, allowedSorts, "name")

		assert.Equal(t, 20, params.Limit)
	})

	t.Run("GivenNegativeLimit_WhenParsed_ThenUseDefault20", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/items?page=1&limit=-5", nil)
		params := parsePaginationParams(req, allowedSorts, "name")

		assert.Equal(t, 20, params.Limit)
	})

	t.Run("GivenLimitOver100_WhenParsed_ThenCapAt100", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/items?page=1&limit=200", nil)
		params := parsePaginationParams(req, allowedSorts, "name")

		assert.Equal(t, 100, params.Limit)
	})

	t.Run("GivenAllowedSort_WhenParsed_ThenUseMappedColumn", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/items?page=1&sort=created_at", nil)
		params := parsePaginationParams(req, allowedSorts, "name")

		assert.Equal(t, "created_at", params.Sort)
	})

	t.Run("GivenDisallowedSort_WhenParsed_ThenUseDefault", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/items?page=1&sort=malicious_column", nil)
		params := parsePaginationParams(req, allowedSorts, "name")

		assert.Equal(t, "name", params.Sort)
	})

	t.Run("GivenAscOrder_WhenParsed_ThenUseASC", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/items?page=1&order=asc", nil)
		params := parsePaginationParams(req, allowedSorts, "name")

		assert.Equal(t, "ASC", params.Order)
	})

	t.Run("GivenDescOrder_WhenParsed_ThenUseDESC", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/items?page=1&order=desc", nil)
		params := parsePaginationParams(req, allowedSorts, "name")

		assert.Equal(t, "DESC", params.Order)
	})

	t.Run("GivenNoOrder_WhenParsed_ThenDefaultDESC", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/items?page=1", nil)
		params := parsePaginationParams(req, allowedSorts, "name")

		assert.Equal(t, "DESC", params.Order)
	})

	t.Run("GivenZeroPage_WhenParsed_ThenDefaultToPage1", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/items?page=0", nil)
		params := parsePaginationParams(req, allowedSorts, "name")

		assert.Equal(t, 1, params.Page)
	})

	t.Run("GivenZeroLimit_WhenParsed_ThenUseDefault20", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/items?page=1&limit=0", nil)
		params := parsePaginationParams(req, allowedSorts, "name")

		assert.Equal(t, 20, params.Limit)
	})
}

// ---------------------------------------------------------------------------
// writePaginatedJSON
// ---------------------------------------------------------------------------

func TestWritePaginatedJSON(t *testing.T) {
	t.Run("GivenDataAndParams_WhenWritten_ThenReturnCorrectEnvelope", func(t *testing.T) {
		rr := httptest.NewRecorder()
		data := []string{"item1", "item2"}
		params := &PaginationParams{Page: 1, Limit: 10, Sort: "name", Order: "ASC"}

		writePaginatedJSON(rr, http.StatusOK, data, 25, params)

		assert.Equal(t, http.StatusOK, rr.Code)

		var resp PaginatedResponse
		err := json.Unmarshal(rr.Body.Bytes(), &resp)
		assert.NoError(t, err)
		assert.Equal(t, 25, resp.Total)
		assert.Equal(t, 1, resp.Page)
		assert.Equal(t, 10, resp.Limit)
		assert.Equal(t, 3, resp.TotalPages) // ceil(25/10) = 3
	})

	t.Run("GivenZeroTotal_WhenWritten_ThenTotalPagesIsZero", func(t *testing.T) {
		rr := httptest.NewRecorder()
		params := &PaginationParams{Page: 1, Limit: 20, Sort: "name", Order: "DESC"}

		writePaginatedJSON(rr, http.StatusOK, []string{}, 0, params)

		var resp PaginatedResponse
		err := json.Unmarshal(rr.Body.Bytes(), &resp)
		assert.NoError(t, err)
		assert.Equal(t, 0, resp.Total)
		assert.Equal(t, 0, resp.TotalPages)
	})

	t.Run("GivenExactMultiple_WhenWritten_ThenTotalPagesExact", func(t *testing.T) {
		rr := httptest.NewRecorder()
		params := &PaginationParams{Page: 1, Limit: 10, Sort: "name", Order: "ASC"}

		writePaginatedJSON(rr, http.StatusOK, []string{}, 30, params)

		var resp PaginatedResponse
		err := json.Unmarshal(rr.Body.Bytes(), &resp)
		assert.NoError(t, err)
		assert.Equal(t, 3, resp.TotalPages) // 30/10 = 3 exactly
	})

	t.Run("GivenSingleItem_WhenWritten_ThenOnePage", func(t *testing.T) {
		rr := httptest.NewRecorder()
		params := &PaginationParams{Page: 1, Limit: 20, Sort: "name", Order: "DESC"}

		writePaginatedJSON(rr, http.StatusOK, []string{"only"}, 1, params)

		var resp PaginatedResponse
		err := json.Unmarshal(rr.Body.Bytes(), &resp)
		assert.NoError(t, err)
		assert.Equal(t, 1, resp.TotalPages)
	})
}
