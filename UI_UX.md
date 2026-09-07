# GauRakshak — UI/UX Specification

## Navigation
- Home
- Cows
- Milk
- Alerts
- More

## Core flow
```text
Splash
 ↓
Login
 ↓
Farm Setup
 ↓
Add Cow
 ↓
Cow Profile
 ↓
Scan Cow
 ↓
Sensor Session
 ↓
Start Milking
 ↓
AI Analysis
 ↓
Risk Result
 ↓
Dashboard
 ↓
Alert / Action
```

## Splash animation
Cow/farm scene → farmer milking cow → milk drop forms → milk drop transitions into GauRakshak interface.

Keep it around 2–3 seconds, with a skip/faster transition after initial use.

## Dashboard
Answer immediately:
- How is my herd?
- Which cows need attention?
- How is today's milk production?

Show herd status, today's milk, attention cows, recent activity and simple trends.

## Cow profile
Cow photo, name, ID/tag, breed/age, current health, mastitis risk, today's milk, alerts and timeline.

## Alerts
Use simple actionable language rather than raw sensor thresholds.

## GauSaathi
Floating assistant button on Home/dashboard.
Example: “Why is Gauri's risk high?”
The assistant explains relevant contributing factors in simple language.

## Design rules
Large text, large touch targets, icon + text, simple charts, local-language support, offline/sync status, minimal typing, hide raw sensor values from primary farmer view.
