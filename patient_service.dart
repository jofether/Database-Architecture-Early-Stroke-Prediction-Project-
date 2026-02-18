import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_model.dart';

class PatientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _patientsCollection = 'patients';
  final String _auditLogsCollection = 'auditLogs';
  final String _usersCollection = 'users';

  // ============ CREATE ============
  /// Creates a new patient record and logs the action to audit trail
  Future<void> createPatient(Patient patient, String userId) async {
    try {
      // Validate patient data before creating
      _validatePatientData(patient);

      // Create the patient document
      await _firestore
          .collection(_patientsCollection)
          .doc(patient.patientId)
          .set(patient.toMap());

      // Log to audit trail
      await _logAuditTrail(
        action: 'create',
        entityType: 'patient',
        entityId: patient.patientId,
        patientId: patient.patientId,
        userId: userId,
        newValue: patient.toMap(),
      );
    } catch (e) {
      throw PatientServiceException('Failed to create patient: $e');
    }
  }

  // ============ READ ============
  /// Gets a single patient by ID
  Future<Patient?> getPatient(String patientId) async {
    try {
      final snapshot =
          await _firestore.collection(_patientsCollection).doc(patientId).get();

      if (!snapshot.exists) {
        return null;
      }

      return Patient.fromMap(snapshot.data() as Map<String, dynamic>);
    } catch (e) {
      throw PatientServiceException('Failed to fetch patient: $e');
    }
  }

  /// Gets all patients (for admins only - consider pagination)
  Future<List<Patient>> getAllPatients({int limit = 100}) async {
    try {
      final snapshot =
          await _firestore.collection(_patientsCollection).limit(limit).get();

      return snapshot.docs
          .map((doc) => Patient.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw PatientServiceException('Failed to fetch patients: $e');
    }
  }

  // ============ UPDATE ============
  /// Updates an existing patient record and logs the change
  Future<void> updatePatient(
      Patient updatedPatient, String userId, Patient oldPatient) async {
    try {
      // Validate patient data before updating
      _validatePatientData(updatedPatient);

      // Update the patient document
      await _firestore
          .collection(_patientsCollection)
          .doc(updatedPatient.patientId)
          .update(updatedPatient.toMap());

      // Log to audit trail with old and new values
      await _logAuditTrail(
        action: 'update',
        entityType: 'patient',
        entityId: updatedPatient.patientId,
        patientId: updatedPatient.patientId,
        userId: userId,
        oldValue: oldPatient.toMap(),
        newValue: updatedPatient.toMap(),
      );
    } catch (e) {
      throw PatientServiceException('Failed to update patient: $e');
    }
  }

  // ============ DELETE ============
  /// Deletes a patient record (soft delete recommended - just mark as inactive)
  Future<void> deletePatient(String patientId, String userId) async {
    try {
      // Get the patient first for audit log
      final patient = await getPatient(patientId);
      if (patient == null) {
        throw PatientServiceException('Patient not found');
      }

      // Delete the document
      await _firestore.collection(_patientsCollection).doc(patientId).delete();

      // Log to audit trail
      await _logAuditTrail(
        action: 'delete',
        entityType: 'patient',
        entityId: patientId,
        patientId: patientId,
        userId: userId,
        oldValue: patient.toMap(),
      );
    } catch (e) {
      throw PatientServiceException('Failed to delete patient: $e');
    }
  }

  // ============ SEARCH & FILTER ============
  /// Find patients with diabetes
  Future<List<Patient>> findDiabeticPatients() async {
    try {
      final snapshot = await _firestore
          .collection(_patientsCollection)
          .where('hasDiabetes', isEqualTo: true)
          .orderBy('lastUpdated', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Patient.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw PatientServiceException('Failed to search diabetic patients: $e');
    }
  }

  /// Find patients with high blood pressure
  Future<List<Patient>> findHypertensionPatients() async {
    try {
      final snapshot = await _firestore
          .collection(_patientsCollection)
          .where('hasHighArterialBP', isEqualTo: true)
          .orderBy('lastUpdated', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Patient.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw PatientServiceException(
          'Failed to search hypertension patients: $e');
    }
  }

  /// Find patients with metabolic syndrome
  Future<List<Patient>> findMetabolicSyndromePatients() async {
    try {
      final snapshot = await _firestore
          .collection(_patientsCollection)
          .where('isMetabolicSyndrome', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => Patient.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw PatientServiceException(
          'Failed to search metabolic syndrome patients: $e');
    }
  }

  /// Find patients by smoking status
  Future<List<Patient>> findSmokingPatients() async {
    try {
      final snapshot = await _firestore
          .collection(_patientsCollection)
          .where('isSmoking', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => Patient.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw PatientServiceException('Failed to search smoking patients: $e');
    }
  }

  /// Find high-risk patients (multiple conditions)
  Future<List<Patient>> findHighRiskPatients() async {
    try {
      final snapshot = await _firestore
          .collection(_patientsCollection)
          .where('isSmoking', isEqualTo: true)
          .where('hasGeneticPredisposition', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => Patient.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw PatientServiceException('Failed to search high-risk patients: $e');
    }
  }

  /// Find patients by age range
  Future<List<Patient>> findPatientsByAgeRange(
      double minAge, double maxAge) async {
    try {
      final snapshot = await _firestore
          .collection(_patientsCollection)
          .where('age', isGreaterThanOrEqualTo: minAge)
          .where('age', isLessThanOrEqualTo: maxAge)
          .get();

      return snapshot.docs
          .map((doc) => Patient.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw PatientServiceException('Failed to search patients by age: $e');
    }
  }

  // ============ VALIDATION ============
  /// Validates patient data before save/update
  void _validatePatientData(Patient patient) {
    if (patient.patientId.isEmpty) {
      throw PatientValidationException('Patient ID cannot be empty');
    }
    if (patient.gender != 0 && patient.gender != 1) {
      throw PatientValidationException('Gender must be 0 (Male) or 1 (Female)');
    }
    if (patient.age <= 0 || patient.age > 150) {
      throw PatientValidationException('Age must be between 0 and 150');
    }
    if (patient.heightCm <= 0 || patient.heightCm > 300) {
      throw PatientValidationException('Height must be between 0 and 300 cm');
    }
    if (patient.weightKg <= 0 || patient.weightKg > 500) {
      throw PatientValidationException('Weight must be between 0 and 500 kg');
    }
    if (patient.waistlineCm <= 0 || patient.waistlineCm > 300) {
      throw PatientValidationException(
          'Waistline must be between 0 and 300 cm');
    }
    if (patient.alcoholConsumption < 0 || patient.alcoholConsumption > 4) {
      throw PatientValidationException(
          'Alcohol consumption must be between 0 and 4');
    }
    if (patient.triglycerideLevel < 0 || patient.triglycerideLevel > 1000) {
      throw PatientValidationException(
          'Triglyceride level must be between 0 and 1000');
    }
    if (patient.hypertensionStage < 0 || patient.hypertensionStage > 3) {
      throw PatientValidationException(
          'Hypertension stage must be between 0 and 3');
    }
  }

  // ============ AUDIT LOGGING ============
  /// Logs actions to audit trail for compliance
  Future<void> _logAuditTrail({
    required String action,
    required String entityType,
    required String entityId,
    required String patientId,
    required String userId,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
    String? details,
  }) async {
    try {
      await _firestore.collection(_auditLogsCollection).add({
        'action': action,
        'entityType': entityType,
        'entityId': entityId,
        'patientId': patientId,
        'userId': userId,
        'oldValue': oldValue,
        'newValue': newValue,
        'timestamp': FieldValue.serverTimestamp(),
        'details': details ?? '',
      });
    } catch (e) {
      // Log error but don't fail the main operation
      print('Error logging to audit trail: $e');
    }
  }

  /// Gets audit history for a patient
  Future<List<Map<String, dynamic>>> getPatientAuditHistory(
      String patientId) async {
    try {
      final snapshot = await _firestore
          .collection(_auditLogsCollection)
          .where('patientId', isEqualTo: patientId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw PatientServiceException('Failed to fetch audit history: $e');
    }
  }
}

// ============ CUSTOM EXCEPTIONS ============
class PatientServiceException implements Exception {
  final String message;
  PatientServiceException(this.message);

  @override
  String toString() => 'PatientServiceException: $message';
}

class PatientValidationException implements Exception {
  final String message;
  PatientValidationException(this.message);

  @override
  String toString() => 'PatientValidationException: $message';
}
