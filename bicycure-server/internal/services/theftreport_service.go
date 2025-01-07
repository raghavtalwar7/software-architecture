package services

import (
	"database/sql"
	"errors"
	"fmt"
	"time"

	"bicycure-server/internal/database"
	"bicycure-server/internal/models"
)

type TheftReportService struct {
	db *database.Database
}

func NewTheftReportService(db *database.Database) *TheftReportService {
	return &TheftReportService{db: db}
}

func (s *TheftReportService) CreateTheftReport(report *models.TheftReport) (*models.TheftReport, error) {
	query := `
        INSERT INTO theft_reports (bicycle_id, reporter_id, theft_date, theft_location, description, reward_amount, status_id)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING report_id, created_at, updated_at
    `
	err := s.db.QueryRow(
		query,
		report.BicycleID,
		report.ReporterID,
		report.TheftDate,
		report.TheftLocation,
		report.Description,
		report.RewardAmount,
		report.StatusID, // theft report status
	).Scan(&report.ID, &report.CreatedAt, &report.UpdatedAt)

	if err != nil {
		return nil, err
	}

	// Update bicycle status to 'stolen'
	// TODO: use enums to store bicycle status
	_, err = s.db.Exec("UPDATE bicycles SET status = 'stolen' WHERE bicycle_id = $1", report.BicycleID)
	if err != nil {
		return nil, err
	}

	return report, nil
}

func (s *TheftReportService) GetTheftReport(id int) (*models.TheftReport, error) {
	query := `
        SELECT report_id, bicycle_id, reporter_id, theft_date, theft_location,
               description, reward_amount, status_id, created_at, updated_at
        FROM theft_reports 
        WHERE report_id = $1`

	report := &models.TheftReport{}
	err := s.db.QueryRow(query, id).Scan(
		&report.ID,
		&report.BicycleID,
		&report.ReporterID,
		&report.TheftDate,
		&report.TheftLocation,
		&report.Description,
		&report.RewardAmount,
		&report.StatusID,
		&report.CreatedAt,
		&report.UpdatedAt,
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, errors.New("report not found")
		}
		return nil, fmt.Errorf("error fetching theft report: %w", err)
	}

	report.TheftDateStr = report.TheftDate.Format("2006-01-02")

	return report, nil
}

func (s *TheftReportService) UpdateTheftReport(report *models.TheftReport) (*models.TheftReport, error) {
	query := `
        UPDATE theft_reports
        SET bicycle_id = $1, reporter_id = $2, theft_date = $3, theft_location = $4,
            description = $5, reward_amount = $6, status_id = $7, updated_at = $8
        WHERE report_id = $9
        RETURNING report_id, bicycle_id, reporter_id, theft_date, theft_location,
                  description, reward_amount, status_id, created_at, updated_at
    `
	updatedReport := &models.TheftReport{}
	err := s.db.QueryRow(query,
		report.BicycleID,
		report.ReporterID,
		report.TheftDate,
		report.TheftLocation,
		report.Description,
		report.RewardAmount,
		report.StatusID,
		time.Now(),
		report.ID,
	).Scan(
		&updatedReport.ID,
		&updatedReport.BicycleID,
		&updatedReport.ReporterID,
		&updatedReport.TheftDate,
		&updatedReport.TheftLocation,
		&updatedReport.Description,
		&updatedReport.RewardAmount,
		&updatedReport.StatusID,
		&updatedReport.CreatedAt,
		&updatedReport.UpdatedAt,
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, errors.New("report not found")
		}
		return nil, fmt.Errorf("error updating theft report: %w", err)
	}

	// Convert TheftDate to string format for JSON output
	updatedReport.TheftDateStr = updatedReport.TheftDate.Format("2006-01-02")

	return updatedReport, nil
}
