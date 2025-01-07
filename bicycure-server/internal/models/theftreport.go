package models

import (
	"time"
)

type TheftReport struct {
	ID            int       `db:"report_id" json:"id"`
	BicycleID     int       `db:"bicycle_id" json:"bicycle_id"`
	ReporterID    int       `db:"reporter_id" json:"reporter_id"`
	TheftDate     time.Time `db:"theft_date" json:"-"`
	TheftDateStr  string    `db:"-" json:"theft_date"`
	TheftLocation string    `db:"theft_location" json:"theft_location"`
	Description   string    `db:"description" json:"description"`
	RewardAmount  float64   `db:"reward_amount" json:"reward_amount"`
	StatusID      int       `db:"status_id" json:"status_id"`
	CreatedAt     time.Time `db:"created_at" json:"created_at"`
	UpdatedAt     time.Time `db:"updated_at" json:"updated_at"`
}

type TheftReportStatus struct {
	ID   int    `db:"status_id" json:"id"`
	Name string `db:"status_name" json:"name"`
}
