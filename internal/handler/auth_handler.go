package handler

import (
	"encoding/json"
	"free-api-news/internal/domain"
	"free-api-news/internal/middleware"
	"free-api-news/internal/util"
	"net/http"
)

type AuthHandler struct {
	authSvc domain.AuthService
}

func NewAuthHandler(authSvc domain.AuthService) *AuthHandler {
	return &AuthHandler{authSvc: authSvc}
}

// Register godoc
// @Summary      Register a new user
// @Description  Register with name, email and password (min 8 chars)
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        request body domain.RegisterRequest true "Register Data"
// @Success      201     {object} util.Response{data=domain.AuthResponse} "registration successful"
// @Failure      400     {object} util.Response
// @Failure      409     {object} util.Response
// @Failure      500     {object} util.Response
// @Router       /auth/register [post]
func (h *AuthHandler) Register(w http.ResponseWriter, r *http.Request) {
	var req domain.RegisterRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		util.BadRequest(w, "invalid request body")
		return
	}

	if req.Name == "" || req.Email == "" || len(req.Password) < 8 {
		util.BadRequest(w, "name, email, and password (min 8 chars) are required")
		return
	}

	resp, err := h.authSvc.Register(r.Context(), &req)
	if err != nil {
		if err.Error() == "email already registered" {
			util.Conflict(w, err.Error())
			return
		}
		util.InternalError(w, err.Error())
		return
	}

	util.Created(w, "registration successful", resp)
}

// Login godoc
// @Summary      Login user
// @Description  Login with email and password to get tokens
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        request body domain.LoginRequest true "Login Credentials"
// @Success      200     {object} util.Response{data=domain.AuthResponse} "login successful"
// @Failure      400     {object} util.Response
// @Failure      401     {object} util.Response
// @Router       /auth/login [post]
func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	var req domain.LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		util.BadRequest(w, "invalid request body")
		return
	}

	if req.Email == "" || req.Password == "" {
		util.BadRequest(w, "email and password are required")
		return
	}

	resp, err := h.authSvc.Login(r.Context(), &req)
	if err != nil {
		util.Unauthorized(w, err.Error())
		return
	}

	util.OK(w, "login successful", resp)
}

// Logout godoc
// @Summary      Logout user
// @Description  Revoke refresh token
// @Tags         auth
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body object{refresh_token=string} true "Logout Request (refresh token to revoke)"
// @Success      200     {object} util.Response "logged out successfully"
// @Failure      400     {object} util.Response
// @Failure      401     {object} util.Response
// @Failure      500     {object} util.Response
// @Router       /auth/logout [post]
func (h *AuthHandler) Logout(w http.ResponseWriter, r *http.Request) {
	var body struct {
		RefreshToken string `json:"refresh_token"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil || body.RefreshToken == "" {
		util.BadRequest(w, "refresh_token is required")
		return
	}

	if err := h.authSvc.Logout(r.Context(), body.RefreshToken); err != nil {
		util.InternalError(w, err.Error())
		return
	}

	util.OK(w, "logged out successfully", nil)
}

// RefreshToken godoc
// @Summary      Refresh token pair
// @Description  Get a new access and refresh token pair using an unexpired refresh token
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        request body domain.RefreshRequest true "Refresh Token"
// @Success      200     {object} util.Response{data=domain.AuthResponse} "token refreshed"
// @Failure      400     {object} util.Response
// @Failure      401     {object} util.Response
// @Router       /auth/refresh [post]
func (h *AuthHandler) RefreshToken(w http.ResponseWriter, r *http.Request) {
	var req domain.RefreshRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.RefreshToken == "" {
		util.BadRequest(w, "refresh_token is required")
		return
	}

	resp, err := h.authSvc.RefreshToken(r.Context(), &req)
	if err != nil {
		util.Unauthorized(w, err.Error())
		return
	}

	util.OK(w, "token refreshed", resp)
}

// Me godoc
// @Summary      Get current user
// @Description  Returns user info based on validated JWT
// @Tags         auth
// @Produce      json
// @Security     BearerAuth
// @Success      200     {object} util.Response{data=domain.User} "authenticated user"
// @Failure      401     {object} util.Response
// @Failure      500     {object} util.Response
// @Router       /auth/me [get]
func (h *AuthHandler) Me(w http.ResponseWriter, r *http.Request) {
	claims, ok := r.Context().Value(middleware.UserClaimsKey).(*util.Claims)
	if !ok {
		util.Unauthorized(w, "unauthorized")
		return
	}

	user, err := h.authSvc.GetProfile(r.Context(), claims.UserID)
	if err != nil {
		util.InternalError(w, err.Error())
		return
	}

	util.OK(w, "authenticated user", user)
}

// UpdateProfile godoc
// @Summary      Update user profile
// @Description  Updates authenticated user profile data
// @Tags         auth
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body domain.UpdateProfileRequest true "Update Data"
// @Success      200     {object} util.Response{data=domain.User} "profile updated"
// @Failure      400     {object} util.Response
// @Failure      401     {object} util.Response
// @Failure      500     {object} util.Response
// @Router       /auth/me [put]
func (h *AuthHandler) UpdateProfile(w http.ResponseWriter, r *http.Request) {
	claims, ok := r.Context().Value(middleware.UserClaimsKey).(*util.Claims)
	if !ok {
		util.Unauthorized(w, "unauthorized")
		return
	}

	var req domain.UpdateProfileRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		util.BadRequest(w, "invalid request body")
		return
	}

	if req.Name == "" {
		util.BadRequest(w, "name is required")
		return
	}

	user, err := h.authSvc.UpdateProfile(r.Context(), claims.UserID, &req)
	if err != nil {
		util.InternalError(w, err.Error())
		return
	}

	util.OK(w, "profile updated successfully", user)
}
