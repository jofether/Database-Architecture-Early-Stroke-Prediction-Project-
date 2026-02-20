# IoT-IAS Diagram Explanation (First Link)

## Overview
This is a **real-time IoT health monitoring and prediction system** designed to collect sensor data from wearable devices, store physiological readings, and generate ML-based health predictions.

## Core Tables & Purpose

### User & Role Management
- **user_data**: User profiles (email, firstName, lastName, createdAt, lastLogin, finalPrediction, currentStateData)
- **role_data**: Role definitions with permissions (roleName, roleDesc, permissionsAllowed)

### Wearable Device Data (Real-Time Sensors)
- **ppg_data** (Photoplethysmography - Heart Rate):
  - userId, rawFileUrl
  - avgBPM (beats per minute)
  - hrv (heart rate variability)
  - spO2 (oxygen saturation)
  - hardwareId, timestamp
  - Purpose: Captures live heart rate and oxygen levels from wearable sensors

- **physiological_data**: General physiological measurements
  - Stores continuous sensor readings from connected devices

### State Management
- **state_data**: Current device/patient state
  - Tracks operational status of sensors and monitoring devices
  - Includes state transitions and timestamps

### Patient Physical & Medical Data
- **Physical State Fields**:
  - gender, age, height, weight, waistline
  
- **Medical Flags State Fields**:
  - familialAF (atrial fibrillation)
  - obstructiveSleepApnea
  - hyperLipidaemia
  - hyperGlycaemia
  - impairedFastingGlycaemia
  - hyperThyroidism
  - adrenalGlandHyperfunction
  - heartFailureWithReducedEjection
  - heartFailureWithPreservedEjection
  - coronaryArteryDisease
  - chronicKidneyDisease
  - bronchialAsthma
  - transientIschemicAttack
  - metabolicSyndromeDiagnosed

- **Lifestyle State Fields**:
  - Smoking status, activity levels, alcohol consumption

### Medication Management
- **medication_data**:
  - medicationName
  - timesPerDay
  - doseInMg
  - Tracks patient medications and dosing schedules

### ML Model Infrastructure
- **model_data**: ML model registry
  - modelName, modelVersion, modelDesc
  - modelDeveloper, timestamp
  - Purpose: Stores versions of prediction models

- **model_desc_data**: Model descriptions and metadata
  - modelDescRawFile, modelDescVersion
  - Tracks model documentation and configuration

- **prediction_data**: Generated predictions
  - Health risk scores from ML models
  - Links predictions to specific models and patients
  - Timestamps for tracking prediction history

### Audit & Logging
- **audit_logs_data** & **admin_logs_data**:
  - Tracks all system changes and admin actions
  - Compliance and security audit trails

## Data Flow Architecture

```
Wearable Devices
    ↓
PPG Data → Physiological Data
    ↓
State Data (device status)
    ↓
ML Models (model_data, model_desc_data)
    ↓
Prediction Data (risk scores)
    ↓
User Dashboard (currentStateData, finalPrediction)
    ↓
Audit Logs (compliance)
```

## Key Differences From Your Structure

| Aspect | Your System | IoT-IAS |
|--------|-----------|---------|
| **Data Input** | Static patient records | Real-time sensor data from wearables |
| **Heart Monitoring** | None | PPG data (continuous heart rate, SPO2, HRV) |
| **Predictions** | Risk scoring logic in code | Separate prediction_data tables with ML models |
| **Model Versioning** | No | Full model registry with versions |
| **State Tracking** | Patient states | Device AND patient states |
| **Scope** | Single organization | Multi-device, multi-sensor ecosystem |

## Use Cases Supported

1. **Continuous Health Monitoring**: Real-time wearable data ingestion
2. **Predictive Analytics**: ML models generating health risk predictions
3. **Medication Tracking**: Detailed medication adherence and dosing
4. **Sensor Management**: Hardware/device state tracking
5. **Audit Compliance**: Full logging of system actions
6. **Model Versioning**: Track and deploy multiple prediction models

## Complexity Level
**High** - This is an enterprise-grade system with sensor integration, ML pipelines, and extensive data collection.
