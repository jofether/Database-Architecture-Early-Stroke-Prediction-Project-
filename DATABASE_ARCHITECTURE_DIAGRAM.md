# Database Architecture Diagram

```mermaid
erDiagram
    USERS ||--o{ AUDIT_LOGS : performs
    PATIENTS ||--o{ AUDIT_LOGS : "references"
    
    USERS {
        string userId PK
        string email
        string name
        string role
        timestamp createdAt
        timestamp lastLogin
    }
    
    PATIENTS {
        string patientId PK
        timestamp lastUpdated
        
        number gender
        number age
        number heightCm
        number weightCm
        number waistlineCm
        
        number alcoholConsumption
        boolean isSmoking
        boolean isPhysicallyInactive
        boolean isExcessivePhysicalActivity
        
        boolean hasGeneticPredisposition
        boolean hasSleepApnea
        boolean hasHyperlipidaemia
        boolean hasHyperglycaemia
        boolean hasImpairedFastingGlycaemia
        boolean hasHyperthyroidism
        boolean hasAdrenalGlandHyperfunction
        boolean hasHeartFailureReducedEF
        boolean hasHeartFailurePreservedEF
        boolean hasCoronaryArteryDisease
        boolean hasChronicKidneyDisease
        boolean hasCOPDorAsthma
        boolean hasStrokeHistory
        
        boolean isMetabolicSyndrome
        boolean hasHighArterialBP
        number triglycerideLevel
        boolean hasHighTriglycerides
        boolean hasLowHDL
        boolean hasDiabetes
        number hypertensionStage
        
        boolean isOnAntihypertensiveTreatment
        string antihypertensiveMedication
        string otherMedication
    }
    
    AUDIT_LOGS {
        string logId PK
        string action
        string entityType
        string entityId
        string userId FK
        string patientId FK
        map oldValue
        map newValue
        timestamp timestamp
        string ipAddress
        string details
    }
```

## Collection Hierarchy

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
│       ├── Basic Info (patientId, lastUpdated)
│       ├── Physical Info (gender, age, height, weight, waistline)
│       ├── Lifestyle (alcohol, smoking, activity level)
│       ├── Medical History (boolean condition flags)
│       ├── Current Conditions (metabolic syndrome, BP, diabetes, etc)
│       └── Medications (antihypertensive, other medications)
│
└── auditLogs/
    └── {logId}
        ├── action
        ├── entityType
        ├── userId (references users)
        ├── patientId (references patients)
        ├── oldValue
        ├── newValue
        └── timestamp
```

## Key Indexes

| Collection | Index | Type |
|-----------|-------|------|
| patients | hasDiabetes, lastUpdated DESC | Composite |
| patients | hasHighArterialBP, lastUpdated DESC | Composite |
| patients | isSmoking, hasGeneticPredisposition | Composite |
| patients | isMetabolicSyndrome, age | Composite |
| auditLogs | entityType, timestamp DESC | Composite |
| auditLogs | userId, timestamp DESC | Composite |
| auditLogs | patientId, timestamp DESC | Composite |
