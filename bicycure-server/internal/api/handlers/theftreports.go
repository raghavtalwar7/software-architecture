package handlers

import (
	"encoding/json"
	"errors"
	"net/http"
	"strconv"
	"time"

	"bicycure-server/internal/models"
	"bicycure-server/internal/services"
	"bicycure-server/pkg/utils"

	"github.com/gorilla/mux"
)

type TheftReportHandler struct {
	theftReportService *services.TheftReportService
}

func NewTheftReportHandler(trs *services.TheftReportService) *TheftReportHandler {
	return &TheftReportHandler{theftReportService: trs}
}

// CreateTheftReport handles the creation of a new theft report
// POST /theft-reports
func (h *TheftReportHandler) CreateTheftReport(w http.ResponseWriter, r *http.Request) {
	var report models.TheftReport

	// Parse and validate request body
	if err := json.NewDecoder(r.Body).Decode(&report); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Set initial status
	report.StatusID = 1

	// Parse theft date if provided
	if report.TheftDateStr != "" {
		theftDate, err := time.Parse("2006-01-02", report.TheftDateStr)
		if err != nil {
			http.Error(w, "Invalid theft date format. Use YYYY-MM-DD", http.StatusBadRequest)
			return
		}
		report.TheftDate = theftDate
	}

	// Create report in database
	createdReport, err := h.theftReportService.CreateTheftReport(&report)
	if err != nil {
		switch {
		case errors.Is(err, utils.ErrValidation):
			http.Error(w, err.Error(), http.StatusBadRequest)
		case errors.Is(err, utils.ErrBicycleNotFound):
			http.Error(w, "Bicycle not found", http.StatusNotFound)
		default:
			http.Error(w, "Failed to create theft report", http.StatusInternalServerError)
		}
		return
	}

	// Format date for response
	createdReport.TheftDateStr = createdReport.TheftDate.Format("2006-01-02")

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(createdReport)
}

// GetTheftReport retrieves a specific theft report by ID
// GET /theft-reports/{id}
func (h *TheftReportHandler) GetTheftReport(w http.ResponseWriter, r *http.Request) {
	// Extract and validate report ID from URL
	reportID, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil {
		http.Error(w, "Invalid report ID", http.StatusBadRequest)
		return
	}

	// Get user ID from context for authorization
	_, ok := r.Context().Value("userID").(int)
	if !ok {
		http.Error(w, "User authentication failed", http.StatusUnauthorized)
		return
	}

	// Retrieve report from database
	report, err := h.theftReportService.GetTheftReport(reportID)
	if err != nil {
		switch {
		case errors.Is(err, utils.ErrReportNotFound):
			http.Error(w, "Theft report not found", http.StatusNotFound)
		case errors.Is(err, utils.ErrUnauthorized):
			http.Error(w, "Not authorized to view this report", http.StatusForbidden)
		default:
			http.Error(w, "Failed to retrieve theft report", http.StatusInternalServerError)
		}
		return
	}

	// Format date for response
	report.TheftDateStr = report.TheftDate.Format("2006-01-02")

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(report)
}

// UpdateTheftReport handles updating an existing theft report
// PUT /theft-reports/{id}
func (h *TheftReportHandler) UpdateTheftReport(w http.ResponseWriter, r *http.Request) {
	// Extract and validate report ID from URL
	reportID, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil {
		http.Error(w, "Invalid report ID", http.StatusBadRequest)
		return
	}

	// Get user ID from context for authorization
	userID, ok := r.Context().Value("userID").(int)
	if !ok {
		http.Error(w, "User authentication failed", http.StatusUnauthorized)
		return
	}

	// Parse and validate request body
	var report models.TheftReport
	if err := json.NewDecoder(r.Body).Decode(&report); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	report.ID = reportID

	// Parse theft date if provided
	if report.TheftDateStr != "" {
		theftDate, err := time.Parse("2006-01-02", report.TheftDateStr)
		if err != nil {
			http.Error(w, "Invalid theft date format. Use YYYY-MM-DD", http.StatusBadRequest)
			return
		}
		report.TheftDate = theftDate
	}

	// Verify user owns the report before updating
	existingReport, err := h.theftReportService.GetTheftReport(reportID)
	if err != nil {
		switch {
		case errors.Is(err, utils.ErrReportNotFound):
			http.Error(w, "Theft report not found", http.StatusNotFound)
		default:
			http.Error(w, "Failed to verify report ownership", http.StatusInternalServerError)
		}
		return
	}

	if existingReport.ReporterID != userID {
		http.Error(w, "Not authorized to update this report", http.StatusForbidden)
		return
	}

	// Update report in database
	updatedReport, err := h.theftReportService.UpdateTheftReport(&report)
	if err != nil {
		switch {
		case errors.Is(err, utils.ErrValidation):
			http.Error(w, err.Error(), http.StatusBadRequest)
		case errors.Is(err, utils.ErrReportNotFound):
			http.Error(w, "Theft report not found", http.StatusNotFound)
		default:
			http.Error(w, "Failed to update theft report", http.StatusInternalServerError)
		}
		return
	}

	// Format date for response
	updatedReport.TheftDateStr = updatedReport.TheftDate.Format("2006-01-02")

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(updatedReport)
}
