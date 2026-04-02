package handler

import (
	"fmt"
	"free-api-news/internal/util"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"time"
)

type UploadHandler struct {
    PublicURL string
}

func NewUploadHandler(publicURL string) *UploadHandler {
	return &UploadHandler{PublicURL: publicURL}
}

// UploadImage godoc
// @Summary      Upload an image
// @Description  Upload an image file (multipart/form-data) and returns its public URL
// @Tags         upload
// @Accept       mpfd
// @Produce      json
// @Security     BearerAuth
// @Param        image formData file true "Image file to upload"
// @Success      200     {object} util.Response{data=object{url=string}} "File uploaded"
// @Failure      400     {object} util.Response
// @Failure      500     {object} util.Response
// @Router       /upload [post]
func (h *UploadHandler) UploadImage(w http.ResponseWriter, r *http.Request) {
	// Limit request body to 1.5 MB (1.5 * 1024 * 1024 bytes)
	const maxUploadSize = 1.5 * 1024 * 1024
	r.Body = http.MaxBytesReader(w, r.Body, int64(maxUploadSize))

	// Parse the multipart form, allocating 1.5 MB in memory
	if err := r.ParseMultipartForm(int64(maxUploadSize)); err != nil {
		util.BadRequest(w, "File is too large (Max 1.5 MB) or invalid multipart form")
		return
	}

	// Get the file from "image" key
	file, handler, err := r.FormFile("image")
	if err != nil {
		util.BadRequest(w, "No image file provided in key 'image'")
		return
	}
	defer file.Close()

	// Ensure the public/uploads directory exists
	uploadDir := "./public/uploads"
	if err := os.MkdirAll(uploadDir, os.ModePerm); err != nil {
		util.InternalError(w, "Failed to create upload directory")
		return
	}

	// Create a unique filename
	ext := filepath.Ext(handler.Filename)
	if ext == "" {
		ext = ".jpg" // fallback extension
	}
	filename := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)
	filepath := filepath.Join(uploadDir, filename)

	// Create a new file on the server
	dst, err := os.Create(filepath)
	if err != nil {
		util.InternalError(w, "Failed to save file")
		return
	}
	defer dst.Close()

	// Copy the uploaded file to the created file
	if _, err := io.Copy(dst, file); err != nil {
		util.InternalError(w, "Failed to write file")
		return
	}

	// Construct public URL
    // PublicURL e.g., "http://103.181.143.73:8081"
	fileURL := fmt.Sprintf("%s/public/uploads/%s", h.PublicURL, filename)

	util.OK(w, "File uploaded successfully", map[string]string{
		"url": fileURL,
	})
}
