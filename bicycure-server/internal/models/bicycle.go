package models

import (
	"time"
)

type Bicycle struct {
	ID             int       `db:"bicycle_id" json:"id"`
	RFIDTag        string    `db:"rfid_tag" json:"rfid_tag"`
	Brand          string    `db:"brand" json:"brand"`
	Model          string    `db:"model" json:"model"`
	Color          string    `db:"color" json:"color"`
	FrameNumber    string    `db:"frame_number" json:"frame_number"`
	CurrentOwnerID int       `db:"current_owner_id" json:"current_owner_id"`
	Status         string    `db:"status" json:"status"`
	CreatedAt      time.Time `db:"created_at" json:"created_at"`
	UpdatedAt      time.Time `db:"updated_at" json:"updated_at"`
}
