package handlers

import (
	"bicycure-server/internal/models"
	"bicycure-server/internal/services"
	"bicycure-server/pkg/utils"
	"encoding/json"
	"errors"
	"net/http"
)

type BicycleHandler struct {
	bicycleService *services.BicycleService
}

func NewBicycleHandler(bs *services.BicycleService) *BicycleHandler {
	return &BicycleHandler{bicycleService: bs}
}

// RegisterBicycle handles the creation of a new bicycle registration
// POST /bicycles
func (h *BicycleHandler) RegisterBicycle(w http.ResponseWriter, r *http.Request) {
	var bicycle models.Bicycle

	// Parse request body
	if err := json.NewDecoder(r.Body).Decode(&bicycle); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Get user ID from context (set by JWT middleware)
	userID, ok := r.Context().Value("userID").(int)
	if !ok {
		http.Error(w, "User authentication failed", http.StatusUnauthorized)
		return
	}

	bicycle.CurrentOwnerID = userID

	// Create bicycle in database
	createdBicycle, err := h.bicycleService.RegisterBicycle(&bicycle)
	if err != nil {
		// Handle specific errors with appropriate status codes
		switch {
		case errors.Is(err, utils.ErrValidation):
			http.Error(w, err.Error(), http.StatusBadRequest)
		case errors.Is(err, utils.ErrDuplicate):
			http.Error(w, err.Error(), http.StatusConflict)
		default:
			http.Error(w, "Failed to register bicycle", http.StatusInternalServerError)
		}
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(createdBicycle)
}

// GetUserBicycles retrieves all bicycles owned by the authenticated user
// GET /bicycles/list
func (h *BicycleHandler) GetUserBicycles(w http.ResponseWriter, r *http.Request) {
	userID, ok := r.Context().Value("userID").(int)
	if !ok {
		http.Error(w, "User authentication failed", http.StatusUnauthorized)
		return
	}

	bicycles, err := h.bicycleService.GetBicyclesByUserID(userID)
	if err != nil {
		http.Error(w, "Failed to fetch bicycles", http.StatusInternalServerError)
		return
	}

	if len(bicycles) == 0 {
		w.WriteHeader(http.StatusNoContent)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(bicycles)
}

type ScanBicycleRequest struct {
	RFID    string `json:"rfid"`
	Place   string `json:"place"`
	City    string `json:"city"`
	Pincode string `json:"pincode"`
}

// ScanBicycle handles the scanning of a bicycle's RFID tag
// POST /bicycles/scan
func (h *BicycleHandler) ScanBicycle(w http.ResponseWriter, r *http.Request) {
	var req ScanBicycleRequest

	// Parse and validate request body
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if req.RFID == "" {
		http.Error(w, "RFID is required", http.StatusBadRequest)
		return
	}

	userID, ok := r.Context().Value("userID").(int)
	if !ok {
		http.Error(w, "User authentication failed", http.StatusUnauthorized)
		return
	}

	scan := &models.BicycleScan{
		UserID:      userID,
		ScanPlace:   req.Place,
		ScanCity:    req.City,
		ScanPincode: req.Pincode,
	}

	result, err := h.bicycleService.ScanBicycleByRFID(req.RFID, scan)
	if err != nil {
		switch {
		case errors.Is(err, utils.ErrBicycleNotFound):
			http.Error(w, "Bicycle not found", http.StatusNotFound)
		case errors.Is(err, utils.ErrValidation):
			http.Error(w, err.Error(), http.StatusBadRequest)
		default:
			http.Error(w, "Failed to process scan", http.StatusInternalServerError)
		}
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}
