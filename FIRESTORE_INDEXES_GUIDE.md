# Firestore Composite Indexes Setup Guide

These are the composite indexes needed for the healthcare database. You'll need to create them manually in the Firebase Console.

## How to Create Indexes in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Firestore Database** → **Indexes** tab
4. Click **Create Index**
5. Follow the steps below for each index

---

## Indexes to Create

### 1. **Patients Collection - Diabetes Query**

**Collection:** `patients`

**Fields:**
- `hasDiabetes` (Ascending)
- `lastUpdated` (Descending)

**Purpose:** Fast queries for finding all diabetic patients sorted by most recent

**Query Example:** `db.collection('patients').where('hasDiabetes', '==', true).orderBy('lastUpdated', 'desc')`

---

### 2. **Patients Collection - High Blood Pressure Query**

**Collection:** `patients`

**Fields:**
- `hasHighArterialBP` (Ascending)
- `lastUpdated` (Descending)

**Purpose:** Fast queries for finding patients with hypertension sorted by most recent

**Query Example:** `db.collection('patients').where('hasHighArterialBP', '==', true).orderBy('lastUpdated', 'desc')`

---

### 3. **Patients Collection - Risk Factors Query**

**Collection:** `patients`

**Fields:**
- `isSmoking` (Ascending)
- `hasGeneticPredisposition` (Ascending)

**Purpose:** Find patients with specific lifestyle and genetic risk factors

**Query Example:** `db.collection('patients').where('isSmoking', '==', true).where('hasGeneticPredisposition', '==', true)`

---

### 4. **Patients Collection - Metabolic Syndrome by Age**

**Collection:** `patients`

**Fields:**
- `isMetabolicSyndrome` (Ascending)
- `age` (Ascending)

**Purpose:** Analyze metabolic syndrome distribution by age groups

**Query Example:** `db.collection('patients').where('isMetabolicSyndrome', '==', true).where('age', '>=', 40).where('age', '<=', 65).orderBy('age')`

---

### 5. **Audit Logs Collection - By Entity Type**

**Collection:** `auditLogs`

**Fields:**
- `entityType` (Ascending)
- `timestamp` (Descending)

**Purpose:** View audit trail for specific entity types sorted by recent changes

**Query Example:** `db.collection('auditLogs').where('entityType', '==', 'patient').orderBy('timestamp', 'desc')`

---

### 6. **Audit Logs Collection - By User**

**Collection:** `auditLogs`

**Fields:**
- `userId` (Ascending)
- `timestamp` (Descending)

**Purpose:** Track all changes made by a specific user

**Query Example:** `db.collection('auditLogs').where('userId', '==', 'user123').orderBy('timestamp', 'desc')`

---

### 7. **Audit Logs Collection - By Patient**

**Collection:** `auditLogs`

**Fields:**
- `patientId` (Ascending)
- `timestamp` (Descending)

**Purpose:** View complete audit trail for a specific patient

**Query Example:** `db.collection('auditLogs').where('patientId', '==', 'patient123').orderBy('timestamp', 'desc')`

---

## Step-by-Step in Firebase Console

For each index above:

1. Click **+ Create Index**
2. Select the **Collection ID** (e.g., "patients")
3. Add the first field:
   - Click **Add Field**
   - Enter field name (e.g., "hasDiabetes")
   - Select order type (Ascending or Descending)
4. Add the second field:
   - Click **Add Field** again
   - Enter field name (e.g., "lastUpdated")
   - Select order type
5. Click **Create Index**
6. Wait for the index to build (usually a few seconds to minutes)

---

## Notes

- Single-field indexes are created automatically by Firestore when needed
- Composite indexes (multiple fields) must be created manually
- Indexes increase write costs but significantly speed up queries
- You can delete unused indexes from the same Indexes tab
- Index creation is usually fast, but large collections may take longer

---

## Verification

After creating all indexes, you should see them all listed in the **Indexes** tab with status **Enabled**.

If a query is slow, check if the Firestore console suggests creating an index for that query - it will provide a link to auto-create it.
