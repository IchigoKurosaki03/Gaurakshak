import unittest
from datetime import datetime
from inspect import signature

from app.routers.cows import _get_csv_samples, get_cow_samples


class CsvSampleContractTests(unittest.TestCase):
    def test_latest_samples_are_chronological_and_complete(self) -> None:
        rows = _get_csv_samples("COW_0002", limit=3)

        self.assertEqual(len(rows), 3)
        timestamps = [
            datetime.strptime(
                f"{row['recorded_date']} {row['recorded_time']}", "%d-%m-%Y %H:%M"
            )
            for row in rows
        ]
        self.assertEqual(timestamps, sorted(timestamps))
        self.assertEqual(timestamps[-1], datetime(2026, 6, 29, 18, 0))
        self.assertTrue(
            {
                "milk_ph",
                "milking_duration_minutes",
                "milking_hygiene_score",
                "rumination_minutes",
                "udder_swelling_score",
                "mastitis_current",
            }.issubset(rows[-1])
        )

    def test_preview_endpoint_does_not_require_a_farm_token(self) -> None:
        self.assertNotIn("user", signature(get_cow_samples).parameters)


if __name__ == "__main__":
    unittest.main()
