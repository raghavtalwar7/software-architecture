package models

import (
	"time"
)

type BicycleScan struct {
	ID          int       `db:"scan_id" json:"id"`
	BicycleID   int       `db:"bicycle_id" json:"bicycle_id"`
	UserID      int       `db:"user_id" json:"user_id"`
	ScanDate    time.Time `db:"scan_date" json:"scan_date"`
	ScanPlace   string    `db:"scan_place" json:"place"`
	ScanPincode string    `db:"scan_pincode" json:"pincode"`
	ScanCity    string    `db:"scan_city" json:"city"`
}
