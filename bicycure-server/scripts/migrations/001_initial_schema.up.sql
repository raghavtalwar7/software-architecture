-- 001_initial_schema.sql

-- Users table
CREATE TABLE users (
                       user_id SERIAL PRIMARY KEY,
                       government_id VARCHAR(50) UNIQUE NOT NULL,
                       first_name VARCHAR(50) NOT NULL,
                       last_name VARCHAR(50) NOT NULL,
                       email VARCHAR(100) UNIQUE NOT NULL,
                       phone_number VARCHAR(20),
                       password_hash VARCHAR(255) NOT NULL,
                       created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                       updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Bicycles table
CREATE TABLE bicycles (
                          bicycle_id SERIAL PRIMARY KEY,
                          rfid_tag VARCHAR(50) UNIQUE NOT NULL,
                          brand VARCHAR(50),
                          model VARCHAR(50),
                          color VARCHAR(30),
                          frame_number VARCHAR(50),
                          current_owner_id INTEGER REFERENCES users(user_id),
                          status VARCHAR(20) CHECK (status IN ('active', 'stolen', 'recovered')) DEFAULT 'active',
                          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                          updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Ownership history table
CREATE TABLE ownership_history (
                                   history_id SERIAL PRIMARY KEY,
                                   bicycle_id INTEGER REFERENCES bicycles(bicycle_id),
                                   previous_owner_id INTEGER REFERENCES users(user_id),
                                   new_owner_id INTEGER REFERENCES users(user_id),
                                   transfer_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Theft report status enum table
CREATE TABLE theft_report_status (
                                     status_id SERIAL PRIMARY KEY,
                                     status_name VARCHAR(20) UNIQUE NOT NULL
);

-- Insert initial status values
INSERT INTO theft_report_status (status_name) VALUES ('ACTIVE'), ('RESOLVED'), ('CANCELLED');

-- Theft reports table
CREATE TABLE theft_reports (
                               report_id SERIAL PRIMARY KEY,
                               bicycle_id INTEGER REFERENCES bicycles(bicycle_id),
                               reporter_id INTEGER REFERENCES users(user_id),
                               theft_date TIMESTAMP WITH TIME ZONE NOT NULL,
                               theft_location VARCHAR(255),
                               description TEXT,
                               reward_amount DECIMAL(10, 2),
                               status_id INTEGER REFERENCES theft_report_status(status_id),
                               created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                               updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Bicycle scans table
CREATE TABLE bicycle_scans (
                               scan_id SERIAL PRIMARY KEY,
                               bicycle_id INTEGER REFERENCES bicycles(bicycle_id),
                               user_id INTEGER REFERENCES users(user_id),
                               scan_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                               scan_place VARCHAR(255),
                               scan_pincode VARCHAR(20),
                               scan_city VARCHAR(50)
);

-- User roles table
CREATE TABLE user_roles (
                            role_id SERIAL PRIMARY KEY,
                            user_id INTEGER REFERENCES users(user_id),
                            role VARCHAR(20) CHECK (role IN ('user', 'law_enforcement', 'admin'))
);

-- Create indexes for frequently queried columns
CREATE INDEX idx_bicycles_rfid_tag ON bicycles(rfid_tag);
CREATE INDEX idx_bicycles_status ON bicycles(status);
CREATE INDEX idx_theft_reports_status_id ON theft_reports(status_id);

-- Trigger function to update the updated_at column
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for tables with updated_at column
CREATE TRIGGER update_user_modtime
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_bicycle_modtime
    BEFORE UPDATE ON bicycles
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_theft_report_modtime
    BEFORE UPDATE ON theft_reports
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();