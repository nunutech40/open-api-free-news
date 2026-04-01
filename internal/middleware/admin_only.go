package middleware

import (
	"free-api-news/internal/util"
	"net/http"
)

// AdminOnly middleware ensures the authenticated user has the 'admin' role.
// Must be used AFTER the Auth middleware (which sets UserClaimsKey in context).
func AdminOnly(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(UserClaimsKey).(*util.Claims)
		if !ok {
			util.Unauthorized(w, "unauthorized")
			return
		}
		if claims.Role != "admin" {
			util.Forbidden(w, "forbidden: admin access required")
			return
		}
		next.ServeHTTP(w, r)
	})
}
