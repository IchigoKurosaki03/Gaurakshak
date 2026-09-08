# GauRakshak sensor integration contract

The ESP32 or sensor gateway sends one JSON reading to `POST /sensor-readings`
using the farmer's JWT. Every reading must identify a cow with either the
internal `cow_id` or the farm-scoped `tag_id`, and must contain at least one
measurement.

```json
{
  "tag_id": "COW-024",
  "session_id": 12,
  "timestamp": "2026-09-08T10:30:00Z",
  "milk_yield": 8.2,
  "milk_conductivity": 4.9,
  "milk_temperature": 37.8,
  "body_surface_temperature": 38.2,
  "activity": 63
}
```

The backend validates ranges, resolves the tag only inside the authenticated
farmer's farm, verifies that the session belongs to that cow, and persists the
reading. Close the session with the milking-session completion endpoint before
requesting a prediction. The app then displays the risk estimate and factors.

Units and safe ranges:

- milk yield: litres, 0-100
- conductivity: mS/cm, 0-20
- milk/body temperature: degrees Celsius, 20/25-50
- activity: normalized index, 0-100

Do not put API keys in the device firmware or Flutter app. The gateway should
use HTTPS in deployment and rotate its JWT credentials if a device is lost.
