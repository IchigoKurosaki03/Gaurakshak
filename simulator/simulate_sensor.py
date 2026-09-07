"""Sensor simulator — stands in for the ESP32 until hardware exists.

Posts readings to the SAME endpoint (/sensor-readings) the real device will use.
When the hardware is ready, the ESP32 replaces this script; the backend is unchanged.

Usage (backend must be running, and you need a token):
    python simulate_sensor.py --token <JWT> --tag COW-024 --n 5
"""
import argparse
import random
import time
from datetime import datetime

import requests

BASE_URL = "http://localhost:8000"


def get_token(phone: str = "9999999999", otp: str = "123456") -> str:
    requests.post(f"{BASE_URL}/auth/login", json={"phone": phone})
    r = requests.post(f"{BASE_URL}/auth/verify-otp", json={"phone": phone, "otp": otp})
    r.raise_for_status()
    return r.json()["access_token"]


def post_reading(token: str, tag: str, drift: float):
    payload = {
        "tag_id": tag,
        "timestamp": datetime.utcnow().isoformat(),
        "milk_yield": round(random.uniform(9, 12) - drift, 2),
        "milk_conductivity": round(random.uniform(4.5, 5.2) + drift * 0.3, 2),
        "milk_temperature": round(random.uniform(38.0, 38.6) + drift * 0.1, 2),
        "body_surface_temperature": round(random.uniform(38.8, 39.3) + drift * 0.1, 2),
        "activity": round(random.uniform(55, 72) - drift * 4, 1),
    }
    r = requests.post(
        f"{BASE_URL}/sensor-readings",
        json=payload,
        headers={"Authorization": f"Bearer {token}"},
    )
    r.raise_for_status()
    print("posted", payload)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--token", default=None, help="JWT; auto-fetched with demo login if omitted")
    p.add_argument("--tag", default="COW-024")
    p.add_argument("--n", type=int, default=5)
    p.add_argument("--interval", type=float, default=1.0)
    args = p.parse_args()

    token = args.token or get_token()
    for i in range(args.n):
        # gradually drift toward a riskier profile so predictions get interesting
        post_reading(token, args.tag, drift=i * 0.4)
        time.sleep(args.interval)


if __name__ == "__main__":
    main()
