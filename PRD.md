# Product Requirements Document — GauRakshak

## 1. Product
**Name:** GauRakshak

AI-powered early mastitis risk prediction and cattle health monitoring application for Indian dairy farms.

## 2. Problem
Mastitis can be detected late when farmers depend heavily on manual observation. GauRakshak uses cow/farm records and sensor data to identify changes and provide an early warning.

## 3. Users
- **Farmer/Dairy Worker:** herd health, cow identification, milking sessions, risk results, alerts, GauSaathi.
- **Veterinarian:** cow history, risk trends, contributing factors, health records.
- **Farm Manager:** herd-level status, milk production, alerts and trends.

## 4. MVP journey
1. Login
2. Farm setup
3. Add cow
4. Identify cow using QR/RFID/tag
5. Associate sensor session
6. Start milking
7. Receive sensor data
8. Run ML prediction
9. Show risk result
10. Show dashboard
11. Show alert/action

## 5. Core features
- Phone-based login
- Farm profile
- Cow registration/profile
- Cow identification
- Milking session
- Sensor-data ingestion
- Mastitis risk score
- Low/Medium/High risk
- Cow history and trends
- Herd dashboard
- Alerts
- GauSaathi AI assistant
- Offline capture/synchronization where feasible
- Local-language support

## 6. GauSaathi
GauSaathi is an in-app AI assistant that can answer general cattle-health questions and, with authorized access, explain cow/farm data and risk results.

It must not present itself as a veterinarian or provide definitive diagnosis/prescription.

## 7. Risk result
Example:
- Cow: Gauri
- ID: COW-024
- Risk: High
- Trend: Increasing
- Factors: milk yield decreasing, conductivity increasing, activity decreasing
- Action: check the cow and contact a veterinarian if symptoms are present.

## 8. UX principles
Few taps, large readable controls, simple language, minimal interaction during milking, cow name/photo prominent, simple trends, actionable alerts, offline/sync indication.

## 9. Non-goals for MVP
Automated diagnosis, automatic medicine/antibiotic prescription, complex analytics, and full advanced veterinary workflows.

## 10. Success criteria
The farmer can complete the core journey and understand herd status, cows needing attention, why risk increased, and the next appropriate action.
