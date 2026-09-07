# GauRakshak — Hardware Specification

## Wearable collar
- ESP32
- MPU6050 for activity/movement
- Appropriate contact/surface temperature sensor
- Battery
- Optional local storage

The wearable supplies behavioural and surface-temperature context; it does not directly diagnose mastitis.

## Milking station
Separate from the wearable:
- Milk conductivity
- Milk temperature
- Milk yield
- Periodic SCC/reference measurement

## Cow identification
QR, RFID or ear tag.

The cow ID must be attached to the milking/sensor session.

## Example data packet
```json
{
  "cow_id": "COW-024",
  "sensor_id": "NODE-03",
  "timestamp": "2026-09-04T08:30:00",
  "milk_yield": 8.7,
  "milk_conductivity": 5.2,
  "milk_temperature": 38.1,
  "activity": 61
}
```

## Connectivity
Prototype: Wi-Fi/BLE.
Future: LoRa gateway or cellular connectivity.

## Farmer interaction
Scan cow → verify → associate sensor → start milking → farmer can put phone aside.
