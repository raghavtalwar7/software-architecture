package handlers

import (
	"bicycure-server/internal/models"
	"bicycure-server/internal/services"
	"bicycure-server/pkg/utils"
	"encoding/json"
	"errors"
	"net/http"
)

type UserHandler struct {
	userService *services.UserService
}

func NewUserHandler(us *services.UserService) *UserHandler {
	return &UserHandler{userService: us}
}

// RegisterUser handles new user registration
// POST /users
func (h *UserHandler) RegisterUser(w http.ResponseWriter, r *http.Request) {
	var user models.User

	// Parse and validate request body
	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Create user in database
	createdUser, err := h.userService.RegisterUser(&user)
	if err != nil {
		switch {
		case errors.Is(err, utils.ErrValidation):
			http.Error(w, err.Error(), http.StatusBadRequest)
		case errors.Is(err, utils.ErrDuplicateEmail):
			http.Error(w, "Email already registered", http.StatusConflict)
		default:
			http.Error(w, "Failed to register user", http.StatusInternalServerError)
		}
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(createdUser)
}

// Login authenticates a user and returns a JWT token
// POST /login
func (h *UserHandler) Login(w http.ResponseWriter, r *http.Request) {
	var credentials struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	// Parse and validate request body
	if err := json.NewDecoder(r.Body).Decode(&credentials); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Validate required fields
	if credentials.Email == "" || credentials.Password == "" {
		http.Error(w, "Email and password are required", http.StatusBadRequest)
		return
	}

	// Authenticate user and generate token
	token, err := h.userService.Login(credentials.Email, credentials.Password)
	if err != nil {
		switch {
		case errors.Is(err, utils.ErrInvalidCredentials):
			http.Error(w, "Invalid email or password", http.StatusUnauthorized)
		default:
			http.Error(w, "Authentication failed", http.StatusInternalServerError)
		}
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"token": token})
}
