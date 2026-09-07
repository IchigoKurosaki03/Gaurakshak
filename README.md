# GauRakshak

AI-powered early mastitis risk prediction and cattle health monitoring system for Indian dairy farms.

## MVP flow
Login → Add cow → Identify cow → Start milking → Sensor data → AI/ML analysis → Risk result → Dashboard → Alert/action.

## Main components
- Farmer-facing mobile app
- Cow and farm management
- Milking-session and sensor-data collection
- AI/ML mastitis risk prediction
- Farmer-friendly alerts and explanations
- GauSaathi AI assistant
- Backend API and database
- ESP32-based sensor nodes

> GauRakshak provides an early-warning risk estimate, not a final medical diagnosis.

## Run locally

1. In `backend/`, install dependencies with `python -m pip install -r requirements.txt`.
2. Seed the local development database with `python seed.py`.
3. Start the API with `uvicorn app.main:app --reload`. Open `http://127.0.0.1:8000/docs` to inspect it.
4. In `mobile/`, run `flutter pub get` then `flutter run`.

The local demo account is `9999999999` with OTP `123456`. It is enabled only
when `DEMO_AUTH_ENABLED=true`; never use it in production.

For the local setup checklist, create `backend/venv` and run
`venv\\Scripts\\python create_tables.py`, then
`venv\\Scripts\\python test_db.py`. The current machine uses SQLite for
development. To switch to PostgreSQL, install PostgreSQL, create the database,
and set `DATABASE_URL=postgresql+psycopg://...` in `backend/.env` first.

For an Android emulator the default API address is `http://10.0.2.2:8000`.
For a physical device, pass the computer's HTTPS or LAN address explicitly:

```text
flutter run --dart-define=GAURAKSHAK_API_BASE_URL=https://api.example.com
```

See [SECURITY.md](SECURITY.md) before deploying.
