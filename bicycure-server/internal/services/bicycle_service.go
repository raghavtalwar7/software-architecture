package services

import (
	"bicycure-server/internal/database"
	"bicycure-server/internal/models"
	"fmt"
	"time"
)

type BicycleService struct {
	db *database.Database
}

func NewBicycleService(db *database.Database) *BicycleService {
	return &BicycleService{db: db}
}

func (s *BicycleService) RegisterBicycle(bicycle *models.Bicycle) (*models.Bicycle, error) {
	query := `
        INSERT INTO bicycles (rfid_tag, brand, model, color, frame_number, current_owner_id, status)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING bicycle_id, created_at, updated_at
    `
	err := s.db.QueryRow(
		query,
		bicycle.RFIDTag,
		bicycle.Brand,
		bicycle.Model,
		bicycle.Color,
		bicycle.FrameNumber,
		bicycle.CurrentOwnerID,
		"active",
	).Scan(&bicycle.ID, &bicycle.CreatedAt, &bicycle.UpdatedAt)

	if err != nil {
		return nil, err
	}

	return bicycle, nil
}

func (s *BicycleService) GetBicyclesByUserID(userID int) ([]models.Bicycle, error) {
	query := `SELECT bicycle_id, current_owner_id, brand, model, color, frame_number,status,created_at,updated_at FROM bicycles WHERE current_owner_id = $1`
	rows, err := s.db.Query(query, userID)
	if err != nil {
		fmt.Println(err)
		return nil, err
	}
	defer rows.Close()

	var bicycles []models.Bicycle
	for rows.Next() {
		var b models.Bicycle
		err := rows.Scan(&b.ID, &b.CurrentOwnerID, &b.Brand, &b.Model, &b.Color, &b.FrameNumber, &b.Status, &b.CreatedAt, &b.UpdatedAt)
		if err != nil {
			fmt.Println(err)
			return nil, err
		}
		bicycles = append(bicycles, b)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return bicycles, nil
}

type ScanResult struct {
	Status     string `json:"status"`
	OwnerName  string `json:"owner_name,omitempty"`
	OwnerEmail string `json:"owner_email,omitempty"`
}

func (s *BicycleService) ScanBicycleByRFID(rfid string, scan *models.BicycleScan) (*ScanResult, error) {
	// First, get the bicycle ID and status from the RFID
	query := `SELECT bicycle_id, status FROM bicycles WHERE rfid_tag = $1`
	var bicycleID int
	var status string
	err := s.db.QueryRow(query, rfid).Scan(&bicycleID, &status)
	if err != nil {
		return nil, fmt.Errorf("bicycle not found: %v", err)
	}

	// Record the scan with the new fields
	insertQuery := `
        INSERT INTO bicycle_scans (bicycle_id, user_id, scan_date, scan_place, scan_city, scan_pincode)
        VALUES ($1, $2, $3, $4, $5, $6)
    `
	_, err = s.db.Exec(insertQuery,
		bicycleID,
		scan.UserID,
		time.Now(),
		scan.ScanPlace,
		scan.ScanCity,
		scan.ScanPincode,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to record scan: %v", err)
	}

	// Check if the bicycle is stolen
	if status != "stolen" {
		return &ScanResult{Status: "Not Stolen"}, nil
	}

	// If stolen, retrieve the owner's details
	ownerQuery := `
        SELECT u.first_name, u.last_name, u.email
        FROM bicycles b
        JOIN users u ON b.current_owner_id = u.user_id
        WHERE b.bicycle_id = $1
    `
	var ownerFirstName, ownerLastName, ownerEmail string
	err = s.db.QueryRow(ownerQuery, bicycleID).Scan(&ownerFirstName, &ownerLastName, &ownerEmail)
	if err != nil {
		return nil, fmt.Errorf("failed to retrieve owner info: %v", err)
	}

	return &ScanResult{
		Status:     "Stolen",
		OwnerName:  ownerFirstName + " " + ownerLastName,
		OwnerEmail: ownerEmail,
	}, nil
}
