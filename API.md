# GauRakshak — API Specification

## Authentication
- `POST /auth/login`
- `POST /auth/verify-otp`

## Farms
- `POST /farms`
- `GET /farms/{farm_id}`

## Cows
- `POST /cows`
- `GET /cows`
- `GET /cows/{cow_id}`
- `PATCH /cows/{cow_id}`

## Health records
- `POST /cows/{cow_id}/health-records`
- `GET /cows/{cow_id}/health-records`

## Milking
- `POST /milking-sessions`
- `GET /milking-sessions/{session_id}`
- `POST /milking-sessions/{session_id}/complete`

## Sensors
- `POST /sensor-readings`
- `GET /cows/{cow_id}/sensor-readings`

## Predictions
- `POST /predictions`
- `GET /cows/{cow_id}/risk`

## Alerts
- `GET /alerts`
- `PATCH /alerts/{alert_id}`

## GauSaathi
- `POST /assistant/chat`

The assistant receives the user's question and authorized context/tools; do not expose the whole database to the model.

## Example prediction
```json
{
  "cow_id": "COW-024",
  "risk_score": 0.78,
  "risk_level": "High",
  "trend": "Increasing",
  "contributing_factors": [
    "Milk yield decreasing",
    "Milk conductivity increasing"
  ]
}
```
