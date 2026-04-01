package util

import (
	"encoding/json"
	"net/http"
)

type Response struct {
	Success bool        `json:"success"`
	Message string      `json:"message,omitempty"`
	Data    interface{} `json:"data,omitempty"`
}

func WriteJSON(w http.ResponseWriter, status int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(payload)
}

func OK(w http.ResponseWriter, message string, data interface{}) {
	WriteJSON(w, http.StatusOK, Response{Success: true, Message: message, Data: data})
}

func Created(w http.ResponseWriter, message string, data interface{}) {
	WriteJSON(w, http.StatusCreated, Response{Success: true, Message: message, Data: data})
}

func BadRequest(w http.ResponseWriter, err string) {
	WriteJSON(w, http.StatusBadRequest, Response{Success: false, Message: err})
}

func Unauthorized(w http.ResponseWriter, err string) {
	WriteJSON(w, http.StatusUnauthorized, Response{Success: false, Message: err})
}

func InternalError(w http.ResponseWriter, err string) {
	WriteJSON(w, http.StatusInternalServerError, Response{Success: false, Message: err})
}

func Conflict(w http.ResponseWriter, err string) {
	WriteJSON(w, http.StatusConflict, Response{Success: false, Message: err})
}

func Forbidden(w http.ResponseWriter, err string) {
	WriteJSON(w, http.StatusForbidden, Response{Success: false, Message: err})
}

func NotFound(w http.ResponseWriter, err string) {
	WriteJSON(w, http.StatusNotFound, Response{Success: false, Message: err})
}
