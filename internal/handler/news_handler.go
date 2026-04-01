package handler

import (
	"encoding/json"
	"free-api-news/internal/domain"
	"free-api-news/internal/util"
	"net/http"
	"strconv"
	"strings"
)

type NewsHandler struct {
	newsSvc domain.NewsService
}

func NewNewsHandler(newsSvc domain.NewsService) *NewsHandler {
	return &NewsHandler{newsSvc: newsSvc}
}

// GetCategories godoc
// @Summary      List active categories
// @Description  Returns all active news categories
// @Tags         news
// @Produce      json
// @Success      200 {object} util.Response{data=[]domain.Category}
// @Router       /news/categories [get]
func (h *NewsHandler) GetCategories(w http.ResponseWriter, r *http.Request) {
	categories, err := h.newsSvc.GetCategories(r.Context())
	if err != nil {
		util.InternalError(w, err.Error())
		return
	}
	if categories == nil {
		categories = []*domain.Category{}
	}
	util.OK(w, "categories retrieved", categories)
}

// GetFeed godoc
// @Summary      Get news feed
// @Description  Returns paginated news feed with optional hero article and category filter
// @Tags         news
// @Produce      json
// @Param        category     query string  false "Category slug filter"
// @Param        page         query integer false "Page number (default: 1)"
// @Param        limit        query integer false "Items per page (default: 10, max: 50)"
// @Param        include_hero query boolean false "Separate first article as hero (default: true)"
// @Success      200 {object} util.Response{data=domain.NewsFeedResponse}
// @Router       /news [get]
func (h *NewsHandler) GetFeed(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()

	page, _ := strconv.Atoi(q.Get("page"))
	limit, _ := strconv.Atoi(q.Get("limit"))

	// Default include_hero to true unless explicitly set to false
	includeHero := true
	if strings.ToLower(q.Get("include_hero")) == "false" {
		includeHero = false
	}

	query := &domain.NewsFeedQuery{
		Category:    q.Get("category"),
		Page:        page,
		Limit:       limit,
		IncludeHero: includeHero,
	}

	feed, err := h.newsSvc.GetFeed(r.Context(), query)
	if err != nil {
		util.InternalError(w, err.Error())
		return
	}
	util.OK(w, "feed retrieved", feed)
}

// GetArticle godoc
// @Summary      Get article detail
// @Description  Returns full article content by slug
// @Tags         news
// @Produce      json
// @Param        slug path string true "Article slug"
// @Success      200 {object} util.Response{data=domain.Article}
// @Failure      404 {object} util.Response
// @Router       /news/{slug} [get]
func (h *NewsHandler) GetArticle(w http.ResponseWriter, r *http.Request) {
	// Extract slug from path: /api/v1/news/{slug}
	slug := r.PathValue("slug")
	if slug == "" {
		util.BadRequest(w, "slug is required")
		return
	}

	article, err := h.newsSvc.GetArticleBySlug(r.Context(), slug)
	if err != nil {
		if err.Error() == "article not found" {
			util.NotFound(w, err.Error())
			return
		}
		util.InternalError(w, err.Error())
		return
	}
	util.OK(w, "article retrieved", article)
}

// Ensure json import used (for potential future body parsing)
var _ = json.NewDecoder
