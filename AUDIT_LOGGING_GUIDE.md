# Audit Logging Implementation Guide

This guide explains how to set up audit logging for patient data changes using Cloud Functions.

## Overview

The patient service automatically logs to the `auditLogs` collection whenever a patient record is created, updated, or deleted. This audit trail helps with:
- Compliance and regulatory requirements
- Security monitoring
- Data change tracking
- User accountability

## How It Works

When you use the `PatientService` methods:
- **create()** → Logs with action='create'
- **update()** → Logs with action='update' (includes old and new values)
- **delete()** → Logs with action='delete' (includes old values)

Each audit log entry includes:
- `action`: create, update, or delete
- `entityType`: patient, appointment, etc.
- `entityId`: the patient ID
- `patientId`: the patient being affected
- `userId`: who made the change
- `timestamp`: when it happened
- `oldValue`: previous data (for updates/deletes)
- `newValue`: new data (for creates/updates)

---

## Implementation

### 1. **Dart Service (Already Implemented)**

The `patient_service.dart` includes the `_logAuditTrail()` method that automatically logs all changes:

```dart
// In patient_service.dart
await createPatient(patient, userId);  // Automatically logs to auditLogs
await updatePatient(updatedPatient, userId, oldPatient);  // Logs changes
await deletePatient(patientId, userId);  // Logs deletion
```

### 2. **Optional: Cloud Functions for Additional Logging**

If you want to add server-side logging (e.g., IP address, user agent), create a Cloud Function:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.logPatientAccess = functions.firestore
  .document('patients/{patientId}')
  .onRead(async (snap, context) => {
    const db = admin.firestore();
    const userInfo = context.auth;
    
    if (userInfo) {
      await db.collection('auditLogs').add({
        action: 'read',
        entityType: 'patient',
        entityId: context.params.patientId,
        patientId: context.params.patientId,
        userId: userInfo.uid,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        ipAddress: context.rawRequest.ip,
      });
    }
  });
```

---

## Querying Audit History

### From Dart App

```dart
// Get all changes for a specific patient
final auditHistory = await patientService.getPatientAuditHistory('patient123');

for (var log in auditHistory) {
  print('${log['action']} by ${log['userId']} at ${log['timestamp']}');
}
```

### From Firestore Console

Go to **Firestore Database** → **auditLogs** collection:
- Filter by `patientId` to see all changes for one patient
- Filter by `userId` to see all actions by one user
- Filter by `action` to see only creates, updates, or deletes

---

## Security Considerations

- ✅ Only admins can read audit logs (enforced by Firestore rules)
- ✅ Audit logs are immutable (no updates/deletes allowed)
- ✅ Each change is logged with the user ID
- ✅ Timestamps are server-generated (can't be faked)
- ⚠️ Consider archiving old logs after 1-2 years to save costs
- ⚠️ If using Cloud Functions, log IP addresses carefully (privacy concerns)

---

## Retention & Cleanup

### Manual Cleanup Script

If you want to archive or delete old audit logs after a certain period:

```dart
// Delete audit logs older than 2 years
Future<void> deleteOldAuditLogs(int daysOld) async {
  final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
  
  final snapshot = await FirebaseFirestore.instance
      .collection('auditLogs')
      .where('timestamp', isLessThan: cutoffDate)
      .get();
  
  for (var doc in snapshot.docs) {
    await doc.reference.delete();
  }
}
```

### Firestore TTL (Time-to-Live)

You can also set up automatic deletion using Firestore's TTL feature:
1. Go to **Firestore Database** → **auditLogs** collection
2. Under the collection settings, enable **TTL** on the `timestamp` field
3. Set the duration (e.g., 730 days = 2 years)

---

## Example Audit Log Entry

```json
{
  "action": "update",
  "entityType": "patient",
  "entityId": "P123",
  "patientId": "P123",
  "userId": "nurse_user_456",
  "oldValue": {
    "hasDiabetes": false,
    "lastUpdated": "2026-01-15T10:30:00Z"
  },
  "newValue": {
    "hasDiabetes": true,
    "lastUpdated": "2026-02-17T14:45:00Z"
  },
  "timestamp": "2026-02-17T14:45:00Z",
  "details": ""
}
```

---

## Troubleshooting

**Q: Audit logs aren't being created**
- Check Firestore security rules allow admins to write to auditLogs
- Check users collection has `userId` and `role` fields
- Verify you're passing `userId` to the service methods

**Q: Can't query audit history**
- Confirm you have the required composite indexes
- Check that you're authenticated as admin
- Verify the `patientId` value exists

**Q: Running out of read/write quota**
- Consider archiving old audit logs
- Enable Firestore billing cap
- Increase TTL period or disable archival

---

## Next Steps

1. ✅ Audit logging is built into `patient_service.dart`
2. Deploy the patient service to your app
3. (Optional) Set up Cloud Functions for IP logging
4. Monitor audit logs for suspicious activity
5. Set up automated cleanup for old logs
