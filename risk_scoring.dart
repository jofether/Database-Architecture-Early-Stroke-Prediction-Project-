import 'patient_model.dart';

/// Risk Scoring Algorithm for Patient Health Assessment
///
/// Calculates overall cardiovascular and metabolic risk based on patient data.
/// Scores range from 0 (lowest risk) to 100+ (highest risk).
class RiskScoring {
  /// Calculates overall patient risk score
  /// Returns a score from 0-100+ with risk category
  static RiskScore calculateRiskScore(Patient patient) {
    double totalScore = 0;

    // ============ DEMOGRAPHICS (0-15 points) ============
    totalScore += _ageRisk(patient.age);

    // ============ CLINICAL MEASUREMENTS (0-20 points) ============
    totalScore += _bmiRisk(patient.weightKg, patient.heightCm);
    totalScore += _waistlineRisk(patient.waistlineCm, patient.gender);
    totalScore += _triglyceridRisk(patient.triglycerideLevel);

    // ============ LIFESTYLE FACTORS (0-25 points) ============
    totalScore += _smokingRisk(patient.isSmoking);
    totalScore += _alcoholRisk(patient.alcoholConsumption);
    totalScore += _activityRisk(
        patient.isPhysicallyInactive, patient.isExcessivePhysicalActivity);

    // ============ MEDICAL CONDITIONS (0-30 points) ============
    totalScore += _diabetesRisk(patient.hasDiabetes);
    totalScore += _hypertensionRisk(patient.hasHighArterialBP,
        patient.hypertensionStage, patient.isOnAntihypertensiveTreatment);
    totalScore += _metabolicSyndromeRisk(patient.isMetabolicSyndrome);
    totalScore += _lipidRisk(patient.hasHighTriglycerides, patient.hasLowHDL);
    totalScore += _geneticRisk(patient.hasGeneticPredisposition);
    totalScore += _comorbidityRisk(patient);

    // ============ SEVERE CONDITIONS (0-10 points) ============
    totalScore += _severeConditionRisk(patient);

    // Determine risk category
    RiskCategory category;
    if (totalScore < 20) {
      category = RiskCategory.low;
    } else if (totalScore < 40) {
      category = RiskCategory.moderate;
    } else if (totalScore < 60) {
      category = RiskCategory.high;
    } else {
      category = RiskCategory.veryHigh;
    }

    return RiskScore(
      totalScore: totalScore.toInt(),
      category: category,
      riskFactors: _identifyRiskFactors(patient),
      recommendations: _generateRecommendations(category, patient),
    );
  }

  // ============ RISK CALCULATION METHODS ============

  static double _ageRisk(double age) {
    if (age < 30) return 0;
    if (age < 40) return 2;
    if (age < 50) return 5;
    if (age < 60) return 8;
    if (age < 70) return 12;
    return 15;
  }

  static double _bmiRisk(double weightKg, double heightCm) {
    double heightM = heightCm / 100;
    double bmi = weightKg / (heightM * heightM);

    if (bmi < 18.5) return 2; // Underweight
    if (bmi < 25) return 0; // Normal
    if (bmi < 30) return 4; // Overweight
    if (bmi < 35) return 8; // Obese Class I
    return 12; // Obese Class II+
  }

  static double _waistlineRisk(double waistlineCm, int gender) {
    bool highWaist = (gender == 0 && waistlineCm > 102) || // Male
        (gender == 1 && waistlineCm > 88); // Female

    return highWaist ? 4 : 0;
  }

  static double _triglyceridRisk(double triglycerideLevel) {
    if (triglycerideLevel < 150) return 0;
    if (triglycerideLevel < 200) return 2;
    if (triglycerideLevel < 400) return 5;
    return 8;
  }

  static double _smokingRisk(bool isSmoking) {
    return isSmoking ? 8 : 0;
  }

  static double _alcoholRisk(int alcoholConsumption) {
    switch (alcoholConsumption) {
      case 0:
        return 0; // No consumption
      case 1:
        return 1; // Low
      case 2:
        return 3; // Moderate
      case 3:
        return 6; // High
      case 4:
        return 10; // Very high
      default:
        return 0;
    }
  }

  static double _activityRisk(bool isInactive, bool isExcessive) {
    if (isInactive) return 6;
    if (isExcessive) return 2; // Excessive without proper monitoring
    return 0;
  }

  static double _diabetesRisk(bool hasDiabetes) {
    return hasDiabetes ? 12 : 0;
  }

  static double _hypertensionRisk(bool hasHighBP, int stage, bool onTreatment) {
    double baseScore = 0;

    if (hasHighBP) {
      switch (stage) {
        case 1:
          baseScore = 5;
          break;
        case 2:
          baseScore = 10;
          break;
        case 3:
          baseScore = 15;
          break;
        default:
          baseScore = 0;
      }

      // Reduce score if on treatment
      if (onTreatment) {
        baseScore = baseScore * 0.7;
      }
    }

    return baseScore;
  }

  static double _metabolicSyndromeRisk(bool hasMetabolicSyndrome) {
    return hasMetabolicSyndrome ? 10 : 0;
  }

  static double _lipidRisk(bool hasHighTriglycerides, bool hasLowHDL) {
    double score = 0;
    if (hasHighTriglycerides) score += 3;
    if (hasLowHDL) score += 3;
    return score;
  }

  static double _geneticRisk(bool hasGeneticPredisposition) {
    return hasGeneticPredisposition ? 5 : 0;
  }

  static double _comorbidityRisk(Patient patient) {
    int conditions = 0;

    // Count serious conditions
    if (patient.hasHyperlipidaemia) conditions++;
    if (patient.hasHyperglycaemia) conditions++;
    if (patient.hasHyperthyroidism) conditions++;
    if (patient.hasChronicKidneyDisease) conditions++;
    if (patient.hasCOPDorAsthma) conditions++;
    if (patient.hasSleepApnea) conditions++;

    if (conditions == 0) return 0;
    if (conditions == 1) return 3;
    if (conditions == 2) return 6;
    return 9; // 3 or more conditions
  }

  static double _severeConditionRisk(Patient patient) {
    double score = 0;

    if (patient.hasCoronaryArteryDisease) score += 10;
    if (patient.hasHeartFailureReducedEF) score += 10;
    if (patient.hasHeartFailurePreservedEF) score += 5;
    if (patient.hasChronicKidneyDisease) score += 8;
    if (patient.hasStrokeHistory) score += 10;

    return score;
  }

  // ============ HELPER METHODS ============

  static List<String> _identifyRiskFactors(Patient patient) {
    List<String> factors = [];

    // Lifestyle
    if (patient.isSmoking) factors.add('Active smoker');
    if (patient.isPhysicallyInactive) factors.add('Sedentary lifestyle');
    if (patient.alcoholConsumption > 2) factors.add('Heavy alcohol use');

    // Measurements
    double heightM = patient.heightCm / 100;
    double bmi = patient.weightKg / (heightM * heightM);
    if (bmi > 30) factors.add('Obesity (BMI > 30)');
    if (patient.waistlineCm > 102 && patient.gender == 0 ||
        patient.waistlineCm > 88 && patient.gender == 1) {
      factors.add('Abdominal obesity');
    }

    // Conditions
    if (patient.hasDiabetes) factors.add('Diabetes');
    if (patient.hasHighArterialBP) factors.add('Hypertension');
    if (patient.hasHighTriglycerides) factors.add('High triglycerides');
    if (patient.hasLowHDL) factors.add('Low HDL cholesterol');
    if (patient.isMetabolicSyndrome) factors.add('Metabolic syndrome');
    if (patient.hasGeneticPredisposition) factors.add('Family history');
    if (patient.hasSleepApnea) factors.add('Sleep apnea');

    // Severe conditions
    if (patient.hasCoronaryArteryDisease)
      factors.add('Coronary artery disease');
    if (patient.hasHeartFailureReducedEF)
      factors.add('Heart failure (reduced EF)');
    if (patient.hasChronicKidneyDisease) factors.add('Chronic kidney disease');
    if (patient.hasStrokeHistory) factors.add('Stroke history');

    return factors;
  }

  static List<String> _generateRecommendations(
      RiskCategory category, Patient patient) {
    List<String> recommendations = [];

    switch (category) {
      case RiskCategory.low:
        recommendations = [
          'Maintain current lifestyle',
          'Regular check-ups (annually)',
          'Continue healthy diet and exercise',
        ];
        break;

      case RiskCategory.moderate:
        recommendations = [
          'Schedule regular health assessments (every 6 months)',
          'Implement dietary changes if needed',
          'Increase physical activity to 150 min/week',
          if (patient.isSmoking) 'Consider smoking cessation program',
          if (patient.isPhysicallyInactive) 'Start regular exercise routine',
        ];
        break;

      case RiskCategory.high:
        recommendations = [
          'Frequent monitoring required (quarterly)',
          'Consult with healthcare provider for medication review',
          'Implement comprehensive lifestyle modifications',
          'Monitor blood pressure and glucose regularly',
          if (patient.isSmoking) 'Smoking cessation is critical',
          if (!patient.isOnAntihypertensiveTreatment &&
              patient.hasHighArterialBP)
            'Consider antihypertensive medication',
          if (patient.hasDiabetes) 'Strict glucose control needed',
        ];
        break;

      case RiskCategory.veryHigh:
        recommendations = [
          'Immediate medical consultation required',
          'Close monitoring (monthly or more frequent)',
          'Aggressive management of all risk factors',
          'Consider cardiology referral',
          'Medication optimization is essential',
          'Hospital-grade monitoring may be warranted',
        ];
        break;
    }

    return recommendations;
  }
}

// ============ DATA CLASSES ============

enum RiskCategory { low, moderate, high, veryHigh }

class RiskScore {
  final int totalScore;
  final RiskCategory category;
  final List<String> riskFactors;
  final List<String> recommendations;

  RiskScore({
    required this.totalScore,
    required this.category,
    required this.riskFactors,
    required this.recommendations,
  });

  String get categoryLabel {
    switch (category) {
      case RiskCategory.low:
        return 'Low Risk';
      case RiskCategory.moderate:
        return 'Moderate Risk';
      case RiskCategory.high:
        return 'High Risk';
      case RiskCategory.veryHigh:
        return 'Very High Risk';
    }
  }

  @override
  String toString() {
    return '''
Risk Assessment Report
======================
Overall Risk Score: $totalScore
Risk Category: $categoryLabel

Risk Factors (${riskFactors.length}):
${riskFactors.map((f) => '  • $f').join('\n')}

Recommendations:
${recommendations.map((r) => '  • $r').join('\n')}
''';
  }
}
