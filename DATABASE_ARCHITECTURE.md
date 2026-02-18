DATABASE ARCHI

## Collections Structure

```
firestore/
├── users/
│   └── {userId}
│       ├── email
│       ├── name
│       ├── role
│       ├── createdAt
│       └── lastLogin
│
├── patients/
│   └── {patientId}
│       ├── patientId
│       ├── lastUpdated
│       ├── gender, age, height, weight, waistline
│       ├── smoking, alcohol, activity level
│       ├── medical history flags
│       ├── diabetes, hypertension, metabolic syndrome
│       └── medications
│
└── auditLogs/
    └── {logId}
        ├── action
        ├── userId
        ├── patientId
        └── timestamp
```

WHAT GOES WHERE

1. users Collection
Stores user accounts and their role info.

```
users/{userId}
├── email: string
├── name: string
├── role: string ("admin", "nurse", etc)
├── createdAt: timestamp
└── lastLogin: timestamp
```

---

2. patients Collection
Where all the patient data lives. Everything's stored in one document per patient - demographics, medical history, current conditions, all that stuff.

Root Document: `patients/{patientId}`
```
{
  // Basic Info
  patientId: string
  lastUpdated: timestamp
  
  // Physical Info
  gender: number (0=Male, 1=Female)
  age: number
  heightCm: number
  weightKg: number
  waistlineCm: number
  
  // Lifestyle
  alcoholConsumption: number (0-4 scale)
  isSmoking: boolean
  isPhysicallyInactive: boolean
  isExcessivePhysicalActivity: boolean
  
  // Medical History (all boolean flags)
  hasGeneticPredisposition: boolean
  hasSleepApnea: boolean
  hasHyperlipidaemia: boolean
  hasHyperglycaemia: boolean
  hasImpairedFastingGlycaemia: boolean
  hasHyperthyroidism: boolean
  hasAdrenalGlandHyperfunction: boolean
  hasHeartFailureReducedEF: boolean
  hasHeartFailurePreservedEF: boolean
  hasCoronaryArteryDisease: boolean
  hasChronicKidneyDisease: boolean
  hasCOPDorAsthma: boolean
  hasStrokeHistory: boolean
  
  // Current Conditions
  isMetabolicSyndrome: boolean
  hasHighArterialBP: boolean
  triglycerideLevel: number
  hasHighTriglycerides: boolean
  hasLowHDL: boolean
  hasDiabetes: boolean
  hypertensionStage: number (0-3)
  
  // Medications
  isOnAntihypertensiveTreatment: boolean
  antihypertensiveMedication: string
  otherMedication: string
}
```

---

3. auditLogs Collection
Simple audit trail for tracking who changed what and when. Helps us stay compliant.

```
auditLogs/{logId}
{
  action: string (create, update, delete)
  entityType: string (patient, appointment, etc)
  entityId: string
  userId: string (who did it)
  patientId: string
  
  oldValue: map (optional)
  newValue: map
  
  timestamp: timestamp
  ipAddress: string (optional)
  details: string
}
```

---

INDEXING STRAT

These are the indexes we'll need to create for fast queries:

- Composite Indexes:
```
patients:
  - (hasDiabetes, lastUpdated DESC)
  - (hasHighArterialBP, lastUpdated DESC)
  - (isSmoking, hasGeneticPredisposition)
  - (isMetabolicSyndrome, age)

auditLogs:
  - (entityType, timestamp DESC)
  - (userId, timestamp DESC)
  - (patientId, timestamp DESC)
```

Single Field Indexes (Firestore creates these automatically):**
hasDiabetes, hasHighArterialBP, isMetabolicSyndrome, gender, lastUpdated

---

DESIGN DECISIONS

- Single Document Per Patient
We put everything in one document instead of splitting it across subcollections. Makes reads simpler and keeps things straightforward.

- Medical History as Boolean Flags
Each condition is just a true/false flag (hasDiabetes, hasSleepApnea, etc). Makes it easy to filter patients by risk factors and calculate risk scores. If we need to track when they got diagnosed or progression over time, we can add a subcollection later.

- No Separate Treatment History
Medications and treatment status live in the main document. Again, we can add a separate treatments subcollection if we need to version changes or track historical records.

- Common Queries
- Get a patient's full profile: `patients/{patientId}` (one read)
- Find all diabetic patients: query where `hasDiabetes == true`
- Risk assessment: one document read gives you all the flags you need
- Filter by conditions: query on `isMetabolicSyndrome`, `hasHighArterialBP`, etc.

---

SIZE AND GROWTH

Each patient document is roughly 1.5-3 KB (about 40 fields). Firestore documents can go up to 1 MB, so we're nowhere near that limit.

If we eventually need to track historical data, we can add subcollections later:
- treatments - for medication history
- labResults - for lab result tracking over time
- appointments - for appointment history
- medicalHistory - for tracking when conditions started