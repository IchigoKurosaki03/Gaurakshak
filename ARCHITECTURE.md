# GauRakshak — System Architecture

```text
Farmer
  ↓
Flutter Mobile App
  ↓ REST API
FastAPI Backend
  ├── PostgreSQL/Supabase
  ├── ML Service → XGBoost → Risk Score
  └── GauSaathi → authorized data/tools → Farmer-friendly answer
```

## Hardware path
```text
Cow
 ├── Wearable → activity + surface/contact temperature
 └── Milking station → milk yield + conductivity + milk temperature
                         ↓
                       ESP32
                         ↓
                  Backend / Gateway
                         ↓
                     Database
                         ↓
                   ML prediction
                         ↓
                    Flutter app
```

## Cow identification
```text
QR/RFID/ear tag → Cow verified → Sensor/session associated with cow
```

Every reading needs cow/session identity and timestamp.

## ML path
```text
Indian farm data
 → cleaning/alignment
 → cow history + current readings
 → temporal/trend features where available
 → XGBoost
 → mastitis risk estimate
 → SHAP explanation
 → app
```
