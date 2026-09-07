# GauRakshak — ML Specification

## Objective
Estimate mastitis risk before clinical signs, targeting an early-warning window of 7–14 days.

## Inputs
### Cow
Breed, age, lactation number/DIM, previous mastitis/disease, vaccination/health records.

### Milk
Milk yield, milk conductivity, milk temperature, SCC where available.

### Behaviour
Activity and other available behavioural measures.

### Farm/context
Hygiene, environment, feeding/nutrition, housing and milking procedures.

## Feature engineering
When longitudinal observations are available:
- Moving averages
- Trends/slopes
- Percentage changes
- Deviation from cow baseline
- Conductivity change
- Milk-yield change
- Activity change
- Temperature deviation
- Lactation-stage features

## Model
Initial model: XGBoost.
Compare with Logistic Regression and Random Forest.
Use SHAP for explanation.

## Target
Represent a future mastitis event, e.g. event within next 7 days or next 14 days, rather than simply whether a cow has ever had mastitis.

## Data principle
Final model should be trained/calibrated and validated using Indian farm data. No international model should be presented as the final Indian model.

## Evaluation
Recall/sensitivity, specificity, precision, F1, ROC-AUC and lead time before confirmed diagnosis.

Use animal/time-aware validation to reduce leakage from repeated observations.

## Safety
Output is a risk estimate, not a medical diagnosis.
