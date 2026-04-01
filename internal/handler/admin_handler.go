package handler

import (
	"encoding/json"
	"free-api-news/internal/domain"
	"free-api-news/internal/middleware"
	"free-api-news/internal/util"
	"net/http"
)

type AdminHandler struct {
	newsSvc domain.NewsService
}

func NewAdminHandler(newsSvc domain.NewsService) *AdminHandler {
	return &AdminHandler{newsSvc: newsSvc}
}

// CreateArticle godoc
// @Summary      Create a new article (Admin)
// @Description  Creates a news article. Automatically generates slug and read_time_minutes.
// @Tags         admin
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body domain.CreateArticleRequest true "Article data"
// @Success      201 {object} util.Response{data=domain.Article}
// @Failure      400 {object} util.Response
// @Failure      401 {object} util.Response
// @Failure      403 {object} util.Response
// @Router       /admin/articles [post]
func (h *AdminHandler) CreateArticle(w http.ResponseWriter, r *http.Request) {
	claims, ok := r.Context().Value(middleware.UserClaimsKey).(*util.Claims)
	if !ok {
		util.Unauthorized(w, "unauthorized")
		return
	}

	var req domain.CreateArticleRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		util.BadRequest(w, "invalid request body")
		return
	}

	article, err := h.newsSvc.CreateArticle(r.Context(), claims.UserID, &req)
	if err != nil {
		util.BadRequest(w, err.Error())
		return
	}

	util.Created(w, "article created successfully", article)
}
