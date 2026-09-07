# GauRakshak — Database Design

## users
id, name, phone, role, farm_id

## farms
id, name, location, created_at

## cows
id, farm_id, tag_id, name, breed, date_of_birth, lactation_number, basic_health_status

## health_records
id, cow_id, record_type, date, notes, diagnosis, treatment, vaccination

## milking_sessions
id, cow_id, sensor_id, started_at, ended_at

## sensor_readings
id, cow_id, session_id, timestamp, milk_yield, milk_conductivity, milk_temperature, body_surface_temperature, activity

## predictions
id, cow_id, timestamp, risk_score, risk_level, trend, model_version

## prediction_factors
id, prediction_id, feature, contribution

## alerts
id, cow_id, prediction_id, created_at, severity, message, status

Every sensor reading must have timestamp and cow/session association.
