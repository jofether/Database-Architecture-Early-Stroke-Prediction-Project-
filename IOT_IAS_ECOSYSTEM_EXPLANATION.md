# IoT-IAS Ecosystem Diagram Explanation (Second Link)

## Overview
This is a **multi-tenant healthcare ecosystem platform** that manages multiple independent healthcare organizations, their users, notification systems, and permission/role-based access control. It's focused on **collaboration, notifications, and organizational hierarchy**.

## Core Tables & Purpose

### User Management
- **users**:
  - id, email, firstName, lastName
  - createdAt, lastLogin
  - currentStateData, finalPrediction
  - Single universal user table serving the entire ecosystem
  - Users can belong to multiple ecosystems/organizations

### Organizational Structure (Ecosystem)
- **ecosystem_data** (Healthcare Organization/Team):
  - ecosystemAdmin (who manages the organization)
  - membersCount (total members in org)
  - ecosystemStatus (active/inactive)
  - createdAt, lastActivityAt
  - Purpose: Represents a complete healthcare provider/hospital/clinic

- **ecosystem_members_data** (Organization Membership):
  - userId (which user)
  - ecosystemId (which organization they belong to)
  - memberStatus (active/invited/disabled)
  - permissionsAllowed (what they can do in this org)
  - lastUpdated (membership changes)
  - Purpose: Manages user-to-organization relationships and permissions per org

### Permission & Role Management
- **permission_data**:
  - permissionName (e.g., "view_patients", "edit_medications")
  - permissionDesc (description of what this permission allows)
  - createdAt, lastUpdated
  - Purpose: Define granular permissions in the system
  - Notes: These are referenced in ecosystem_members_data and role_data

### Status Management
- **status_data**:
  - status_name (e.g., "active", "pending_approval", "suspended")
  - status_ui_color (color for UI display)
  - createdAt, lastUpdated
  - Purpose: Standardized status values for workflows (users, ecosystems, invitations, etc)

### Notification System
- **notifications_data** (User Notifications):
  - receiverId (which user receives it)
  - notifType (links to notif_type_data)
  - notifTitle, notifContent
  - notifButtons (call-to-action buttons in notification)
  - createdAt, isRead, readAt
  - Purpose: Push notifications, alerts, and messages to users

- **notif_type_data** (Notification Templates):
  - notifTypeName (e.g., "urgent_alert", "medication_reminder", "patient_update")
  - notifTypeDesc
  - createdAt, lastUpdated
  - Purpose: Defines types of notifications the system can send

## Data Flow Architecture

```
Healthcare Organizations (Ecosystem)
    ↓
Ecosystem Members (Users assigned to orgs)
    ↓
Permissions (What each member can do)
    ↓
Notifications (Alerts for important events)
    ↓
User Dashboard (See alerts, status updates)
```

## Key Relationships

```
users →─────────────────────────→ ecosystem_members_data
         (belongs to)                    ↓
                          ecosystem_data (which org)
                                    ↓
                          permission_data (member permissions)

users ←────────── notifications_data
         (receives)     ↓
                  notif_type_data (notification type)

anything ────→ status_data (for status values)
       (has state)
```

## Multi-Tenant Capabilities

This system supports:
- **Multiple Independent Organizations**: Each ecosystem is isolated
- **User Registration Across Orgs**: One user can join multiple organizations with different roles
- **Organization-Specific Permissions**: Same user has different permissions in different orgs
- **Cross-Organization Notifications**: Users can receive notifications from their ecosystems
- **Admin Per Organization**: Each ecosystem has its own admin

Example:
```
Dr. John (user_id: 123)
├── Hospital A (ecosystemId: 1) → Permissions: view_all_patients, write_prescriptions
├── Clinic B (ecosystemId: 2) → Permissions: view_own_patients
└── Research Institute C (ecosystemId: 3) → Permissions: view_anonymized_data
```

## Notification Workflow Example

```
Patient Alert Generated
    ↓
Create notification_data record
├── receiverId: 123 (send to Dr. John)
├── notifType: "critical_bp_alert" (use template)
├── notifTitle: "Critical Blood Pressure"
├── notifContent: "Patient P-456 has critical BP reading"
├── notifButtons: ["View Patient", "Acknowledge"]
└── isRead: false
    ↓
User sees notification
    ↓
User clicks button or reads
    ↓
Update readAt timestamp
```

## Key Differences From Your Structure

| Aspect | Your System | Ecosystem |
|--------|-----------|-----------|
| **Organizations** | Single organization | Multiple organizations (multi-tenant) |
| **Users** | Users with roles | Users with org-specific roles/permissions |
| **Notifications** | None | Central notification system |
| **Permission Granularity** | Basic roles | Fine-grained per-organization permissions |
| **Status Tracking** | Minimal | Standardized status system |
| **Collaboration** | No | Built for cross-organization workflows |
| **Scalability** | Limited | Enterprise-scale multi-tenant |

## Use Cases Supported

1. **Multi-Hospital Networks**: Manage multiple healthcare facilities
2. **User Invitations**: Invite users to join organizations
3. **Role Segregation**: Different roles in different organizations
4. **Real-Time Alerts**: Notify users about critical events
5. **Activity Tracking**: Monitor user presence and organization activity
6. **Audit-Ready**: Track membership changes and permissions
7. **Flexible Onboarding**: Support multiple org joinings per user

## Complexity Level
**Medium-High** - This is a sophisticated multi-tenant platform architecture with complex permission and notification workflows, but simpler than the sensor-based IoT system.

## Architecture Pattern
**Multi-Tenant SaaS Pattern** - Designed to serve multiple independent healthcare organizations from a single database infrastructure while maintaining complete data isolation and customization per organization.
