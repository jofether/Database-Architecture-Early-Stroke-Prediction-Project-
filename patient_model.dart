import 'package:cloud_firestore/cloud_firestore.dart';

// ============ PPG SENSOR DATA (from IoT-IAS) ============
class PPGData {
  final String? hardwareId;
  final int? avgBPM; // Average Beats Per Minute
  final int? hrv; // Heart Rate Variability
  final int? spO2; // Oxygen Saturation
  final DateTime? timestamp;

  PPGData({
    this.hardwareId,
    this.avgBPM,
    this.hrv,
    this.spO2,
    this.timestamp,
  });

  factory PPGData.fromMap(Map<String, dynamic> map) {
    return PPGData(
      hardwareId: map['hardwareId'],
      avgBPM: map['avgBPM'],
      hrv: map['hrv'],
      spO2: map['spO2'],
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hardwareId': hardwareId,
      'avgBPM': avgBPM,
      'hrv': hrv,
      'spO2': spO2,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
    };
  }
}

// ============ ML PREDICTION DATA (from IoT-IAS) ============
class PredictionData {
  final String? modelVersion;
  final double? riskScore; // Overall health risk score (0-100)
  final DateTime? predictionTimestamp;
  final String? predictionStatus; // 'pending', 'completed', 'failed'

  PredictionData({
    this.modelVersion,
    this.riskScore,
    this.predictionTimestamp,
    this.predictionStatus,
  });

  factory PredictionData.fromMap(Map<String, dynamic> map) {
    return PredictionData(
      modelVersion: map['modelVersion'],
      riskScore: (map['riskScore'] as num?)?.toDouble(),
      predictionTimestamp: map['predictionTimestamp'] != null
          ? (map['predictionTimestamp'] as Timestamp).toDate()
          : null,
      predictionStatus: map['predictionStatus'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'modelVersion': modelVersion,
      'riskScore': riskScore,
      'predictionTimestamp': predictionTimestamp != null
          ? Timestamp.fromDate(predictionTimestamp!)
          : null,
      'predictionStatus': predictionStatus,
    };
  }
}

// ============ NOTIFICATION (from IoT-IAS-Ecosystem) ============
class PatientNotification {
  final String? notifId;
  final String? notifType; // 'critical_alert', 'medication_reminder', etc
  final String? notifTitle;
  final String? notifContent;
  final List<String>? notifButtons;
  final DateTime? createdAt;
  final bool? isRead;
  final DateTime? readAt;

  PatientNotification({
    this.notifId,
    this.notifType,
    this.notifTitle,
    this.notifContent,
    this.notifButtons,
    this.createdAt,
    this.isRead,
    this.readAt,
  });

  factory PatientNotification.fromMap(Map<String, dynamic> map) {
    return PatientNotification(
      notifId: map['notifId'],
      notifType: map['notifType'],
      notifTitle: map['notifTitle'],
      notifContent: map['notifContent'],
      notifButtons: List<String>.from(map['notifButtons'] ?? []),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      isRead: map['isRead'],
      readAt:
          map['readAt'] != null ? (map['readAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notifId': notifId,
      'notifType': notifType,
      'notifTitle': notifTitle,
      'notifContent': notifContent,
      'notifButtons': notifButtons,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }
}

class Patient {
  // Basic Info
  final String patientId;
  final DateTime lastUpdated;

  // Ecosystem & Organization (from IoT-IAS-Ecosystem)
  final String? ecosystemId; // Multi-tenant support
  final String? status; // 'active', 'pending', 'suspended'
  final List<String>? permissionsAllowed; // User permissions in this ecosystem

  // Physical Info
  final int gender; // 0: Male, 1: Female
  final double age;
  final double heightCm;
  final double weightKg;
  final double waistlineCm;

  // Lifestyle
  final int alcoholConsumption; // 0-4 scale
  final bool isSmoking;
  final bool isPhysicallyInactive;
  final bool isExcessivePhysicalActivity;

  // Medical History (all boolean flags)
  final bool hasGeneticPredisposition;
  final bool hasSleepApnea;
  final bool hasHyperlipidaemia;
  final bool hasHyperglycaemia;
  final bool hasImpairedFastingGlycaemia;
  final bool hasHyperthyroidism;
  final bool hasAdrenalGlandHyperfunction;
  final bool hasHeartFailureReducedEF;
  final bool hasHeartFailurePreservedEF;
  final bool hasCoronaryArteryDisease;
  final bool hasChronicKidneyDisease;
  final bool hasCOPDorAsthma;
  final bool hasStrokeHistory;

  // Current Conditions
  final bool isMetabolicSyndrome;
  final bool hasHighArterialBP;
  final double triglycerideLevel;
  final bool hasHighTriglycerides;
  final bool hasLowHDL;
  final bool hasDiabetes;
  final int hypertensionStage;

  // Medications
  final bool isOnAntihypertensiveTreatment;
  final String antihypertensiveMedication;
  final String otherMedication;

  // Sensor Data (from IoT-IAS)
  final PPGData? sensorData;

  // ML Prediction Data (from IoT-IAS)
  final PredictionData? predictionData;

  Patient({
    required this.patientId,
    required this.lastUpdated,
    required this.gender,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.waistlineCm,
    required this.alcoholConsumption,
    required this.isSmoking,
    required this.isPhysicallyInactive,
    required this.isExcessivePhysicalActivity,
    required this.hasGeneticPredisposition,
    required this.hasSleepApnea,
    required this.hasHyperlipidaemia,
    required this.hasHyperglycaemia,
    required this.hasImpairedFastingGlycaemia,
    required this.hasHyperthyroidism,
    required this.hasAdrenalGlandHyperfunction,
    required this.hasHeartFailureReducedEF,
    required this.hasHeartFailurePreservedEF,
    required this.hasCoronaryArteryDisease,
    required this.hasChronicKidneyDisease,
    required this.hasCOPDorAsthma,
    required this.hasStrokeHistory,
    required this.isMetabolicSyndrome,
    required this.hasHighArterialBP,
    required this.triglycerideLevel,
    required this.hasHighTriglycerides,
    required this.hasLowHDL,
    required this.hasDiabetes,
    required this.hypertensionStage,
    required this.isOnAntihypertensiveTreatment,
    required this.antihypertensiveMedication,
    required this.otherMedication,
    this.ecosystemId,
    this.status,
    this.permissionsAllowed,
    this.sensorData,
    this.predictionData,
  });

  // Convert Firebase Map to Dart Object
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      patientId: map['patientId'] ?? '',
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
      gender: map['gender'] ?? 0,
      age: (map['age'] as num?)?.toDouble() ?? 0.0,
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 0.0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      waistlineCm: (map['waistlineCm'] as num?)?.toDouble() ?? 0.0,
      alcoholConsumption: map['alcoholConsumption'] ?? 0,
      isSmoking: map['isSmoking'] ?? false,
      isPhysicallyInactive: map['isPhysicallyInactive'] ?? false,
      isExcessivePhysicalActivity: map['isExcessivePhysicalActivity'] ?? false,
      hasGeneticPredisposition: map['hasGeneticPredisposition'] ?? false,
      hasSleepApnea: map['hasSleepApnea'] ?? false,
      hasHyperlipidaemia: map['hasHyperlipidaemia'] ?? false,
      hasHyperglycaemia: map['hasHyperglycaemia'] ?? false,
      hasImpairedFastingGlycaemia: map['hasImpairedFastingGlycaemia'] ?? false,
      hasHyperthyroidism: map['hasHyperthyroidism'] ?? false,
      hasAdrenalGlandHyperfunction:
          map['hasAdrenalGlandHyperfunction'] ?? false,
      hasHeartFailureReducedEF: map['hasHeartFailureReducedEF'] ?? false,
      hasHeartFailurePreservedEF: map['hasHeartFailurePreservedEF'] ?? false,
      hasCoronaryArteryDisease: map['hasCoronaryArteryDisease'] ?? false,
      hasChronicKidneyDisease: map['hasChronicKidneyDisease'] ?? false,
      hasCOPDorAsthma: map['hasCOPDorAsthma'] ?? false,
      hasStrokeHistory: map['hasStrokeHistory'] ?? false,
      isMetabolicSyndrome: map['isMetabolicSyndrome'] ?? false,
      hasHighArterialBP: map['hasHighArterialBP'] ?? false,
      triglycerideLevel: (map['triglycerideLevel'] as num?)?.toDouble() ?? 0.0,
      hasHighTriglycerides: map['hasHighTriglycerides'] ?? false,
      hasLowHDL: map['hasLowHDL'] ?? false,
      hasDiabetes: map['hasDiabetes'] ?? false,
      hypertensionStage: map['hypertensionStage'] ?? 0,
      isOnAntihypertensiveTreatment:
          map['isOnAntihypertensiveTreatment'] ?? false,
      antihypertensiveMedication: map['antihypertensiveMedication'] ?? '',
      otherMedication: map['otherMedication'] ?? '',
      // New fields from IoT-IAS & IoT-IAS-Ecosystem
      ecosystemId: map['ecosystemId'],
      status: map['status'] ?? 'active',
      permissionsAllowed: List<String>.from(map['permissionsAllowed'] ?? []),
      sensorData: map['sensorData'] != null
          ? PPGData.fromMap(map['sensorData'] as Map<String, dynamic>)
          : null,
      predictionData: map['predictionData'] != null
          ? PredictionData.fromMap(
              map['predictionData'] as Map<String, dynamic>)
          : null,
    );
  }

  // Convert Dart Object to Map (to save to database)
  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'gender': gender,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'waistlineCm': waistlineCm,
      'alcoholConsumption': alcoholConsumption,
      'isSmoking': isSmoking,
      'isPhysicallyInactive': isPhysicallyInactive,
      'isExcessivePhysicalActivity': isExcessivePhysicalActivity,
      'hasGeneticPredisposition': hasGeneticPredisposition,
      'hasSleepApnea': hasSleepApnea,
      'hasHyperlipidaemia': hasHyperlipidaemia,
      'hasHyperglycaemia': hasHyperglycaemia,
      'hasImpairedFastingGlycaemia': hasImpairedFastingGlycaemia,
      'hasHyperthyroidism': hasHyperthyroidism,
      'hasAdrenalGlandHyperfunction': hasAdrenalGlandHyperfunction,
      'hasHeartFailureReducedEF': hasHeartFailureReducedEF,
      'hasHeartFailurePreservedEF': hasHeartFailurePreservedEF,
      'hasCoronaryArteryDisease': hasCoronaryArteryDisease,
      'hasChronicKidneyDisease': hasChronicKidneyDisease,
      'hasCOPDorAsthma': hasCOPDorAsthma,
      'hasStrokeHistory': hasStrokeHistory,
      'isMetabolicSyndrome': isMetabolicSyndrome,
      'hasHighArterialBP': hasHighArterialBP,
      'triglycerideLevel': triglycerideLevel,
      'hasHighTriglycerides': hasHighTriglycerides,
      'hasLowHDL': hasLowHDL,
      'hasDiabetes': hasDiabetes,
      'hypertensionStage': hypertensionStage,
      'isOnAntihypertensiveTreatment': isOnAntihypertensiveTreatment,
      'antihypertensiveMedication': antihypertensiveMedication,
      'otherMedication': otherMedication,
      // New fields from IoT-IAS & IoT-IAS-Ecosystem
      'ecosystemId': ecosystemId,
      'status': status,
      'permissionsAllowed': permissionsAllowed,
      'sensorData': sensorData?.toMap(),
      'predictionData': predictionData?.toMap(),
    };
  }
}
