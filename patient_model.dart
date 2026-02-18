import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  // Basic Info
  final String patientId;
  final DateTime lastUpdated;

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
    };
  }
}
