package middleware

import (
	"net/http"

	"github.com/tiagofur/solennix-backend/internal/i18n"
)

// Localization resolves request locale from Accept-Language and stores it in context.
// Supported locales are normalized by i18n.NormalizeLocale with a safe fallback.
func Localization() func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			locale := i18n.LocaleFromRequest(r)
			ctx := i18n.WithLocale(r.Context(), locale)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}
