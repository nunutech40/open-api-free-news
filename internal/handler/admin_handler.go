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
// @Description  Creates a news article. Slug is auto-generated from the title. read_time_minutes is auto-calculated (200 words/min). published_at is set automatically when status=published.
// @Tags         admin
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request  body      domain.CreateArticleRequest  true  "Article payload"
// @Success      201      {object}  util.Response{data=domain.Article}  "article created"
// @Failure      400      {object}  util.Response
// @Failure      401      {object}  util.Response
// @Failure      403      {object}  util.Response  "admin access required"
// @Failure      500      {object}  util.Response
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
