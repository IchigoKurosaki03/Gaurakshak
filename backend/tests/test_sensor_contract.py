import unittest

from pydantic import ValidationError

from app.schemas import SensorReadingCreate


class SensorReadingContractTests(unittest.TestCase):
    def test_esp32_payload_with_tag_is_accepted(self) -> None:
        reading = SensorReadingCreate(
            tag_id="COW-024",
            milk_yield=8.2,
            milk_conductivity=4.9,
            milk_temperature=37.8,
            body_surface_temperature=38.2,
            activity=63,
        )
        self.assertEqual(reading.tag_id, "COW-024")

    def test_impossible_sensor_values_are_rejected(self) -> None:
        with self.assertRaises(ValidationError):
            SensorReadingCreate(tag_id="COW-024", milk_temperature=74)


if __name__ == "__main__":
    unittest.main()
