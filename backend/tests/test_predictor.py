import math
import unittest

from app.ml.predictor import RiskFeatures, feature_vector, predict_risk


class PredictorContractTests(unittest.TestCase):
    def test_feature_vector_has_stable_order_and_missing_values(self) -> None:
        vector = feature_vector(RiskFeatures(history_count=2, milk_yield=8.0))
        self.assertEqual(len(vector), 9)
        self.assertEqual(vector[0], 2.0)
        self.assertEqual(vector[1], 8.0)
        self.assertEqual(vector[2], 0.0)

    def test_non_finite_sensor_value_is_not_classified_as_low_risk(self) -> None:
        result = predict_risk(
            RiskFeatures(history_count=3, milk_conductivity=math.nan)
        )
        self.assertEqual(result.risk_level, "Insufficient")


if __name__ == "__main__":
    unittest.main()
