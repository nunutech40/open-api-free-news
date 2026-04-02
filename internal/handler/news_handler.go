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
// @Description  Returns all active news categories available as filter chips in the feed UI
// @Tags         news
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  util.Response{data=[]domain.Category}  "list of active categories"
// @Failure      401  {object}  util.Response
// @Failure      500  {object}  util.Response
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
// @Description  Returns a paginated news feed. When include_hero=true (default), the first article on page 1 is separated as hero_article for the Flutter Hero+Grid UI. Supports infinite scroll via the page query param.
// @Tags         news
// @Produce      json
// @Security     BearerAuth
// @Param        category     query    string   false  "Filter by category slug (e.g. 'technology', 'sports')"
// @Param        q            query    string   false  "Search keyword"
// @Param        page         query    integer  false  "Page number, starts at 1"       default(1)
// @Param        limit        query    integer  false  "Items per page, max 50"         default(10)
// @Param        include_hero query    boolean  false  "Separate first article as hero" default(true)
// @Success      200  {object}  util.Response{data=domain.NewsFeedResponse}  "paginated feed"
// @Failure      401  {object}  util.Response
// @Failure      500  {object}  util.Response
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
		Search:      q.Get("q"),
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
// @Description  Returns the full content of a single article by its URL slug
// @Tags         news
// @Produce      json
// @Security     BearerAuth
// @Param        slug  path      string  true  "Article slug (e.g. 'apples-ai-leap-iphone-16-pro')"
// @Success      200   {object}  util.Response{data=domain.Article}  "article detail"
// @Failure      400   {object}  util.Response
// @Failure      401   {object}  util.Response
// @Failure      404   {object}  util.Response
// @Failure      500   {object}  util.Response
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

// Ensure correct imports are used
var _ = json.NewDecoder
