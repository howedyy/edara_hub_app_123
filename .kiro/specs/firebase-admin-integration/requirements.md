# Requirements Document - Firebase Admin Integration & User Approval System

## Introduction

The Edara Hub app currently uses a backend API for event management and user authentication. To address backend team dependencies, this feature integrates Firebase/Firestore as the primary database while introducing a web-based admin panel for managing events and approving user registrations. The system will maintain the existing Flutter mobile app while adding administrative capabilities through a separate web interface.

## Glossary

- **Firebase**: Google's cloud platform providing authentication, database, and hosting services
- **Firestore**: Firebase's NoSQL document database for storing application data
- **Admin Panel**: Web-based interface for administrators to manage events and user approvals
- **Mobile App**: Existing Flutter application in the `lib` directory
- **User Approval**: Process where admins verify and activate new user registrations
- **Event Visibility**: Control mechanism determining which users can see specific events
- **Selected Users**: Specific employees chosen by admins to view particular events
- **Event Publishing**: Action of making an event visible to selected users in the mobile app

## Requirements

### Requirement 1

**User Story:** As an administrator, I want to manage user registrations, so that I can control who has access to the application.

#### Acceptance Criteria

1. WHEN a new user registers through the mobile app THEN the system SHALL store the registration in Firestore with `approved: false` status
2. WHEN an admin views pending registrations in the admin panel THEN the system SHALL display all unapproved users with their registration details
3. WHEN an admin approves a user registration THEN the system SHALL update the user's `approved` status to `true` in Firestore
4. WHEN an admin rejects a user registration THEN the system SHALL delete the user record from Firestore and notify the mobile app
5. WHEN a user attempts to access the mobile app with `approved: false` status THEN the system SHALL prevent access and display an approval pending message

---

### Requirement 2

**User Story:** As an administrator, I want to create and publish events, so that I can communicate important information to employees.

#### Acceptance Criteria

1. WHEN an admin creates an event in the admin panel THEN the system SHALL store the event in Firestore with all required fields (title, description, category, dates, times, location)
2. WHEN an admin publishes an event THEN the system SHALL set `is_published: true` in Firestore and make it visible to selected users
3. WHEN an admin sets event visibility to "all_users" THEN the system SHALL make the event visible to all approved users in the mobile app
4. WHEN an admin sets event visibility to "selected_users" THEN the system SHALL only show the event to users in the `allowed_users` list
5. WHEN an admin uploads media (images/videos) for an event THEN the system SHALL store media files in Firebase Storage and reference them in the event document

---

### Requirement 3

**User Story:** As an administrator, I want to select which users can see specific events, so that I can target events to relevant employees.

#### Acceptance Criteria

1. WHEN an admin creates an event with "selected_users" visibility THEN the system SHALL provide a user selection interface in the admin panel
2. WHEN an admin selects users for an event THEN the system SHALL store their IDs in the event's `allowed_users` array in Firestore
3. WHEN an admin modifies the allowed users list for a published event THEN the system SHALL update the Firestore document and reflect changes immediately in the mobile app
4. WHEN a user is not in the `allowed_users` array for a "selected_users" event THEN the system SHALL prevent that user from viewing or registering for the event in the mobile app
5. WHEN an admin removes a user from an event's allowed list THEN the system SHALL unregister that user from the event if they were already registered

---

### Requirement 4

**User Story:** As a mobile app user, I want to see only events I'm allowed to view, so that I can find relevant events to attend.

#### Acceptance Criteria

1. WHEN a user opens the mobile app with `approved: true` status THEN the system SHALL fetch all published events from Firestore where visibility is "all_users" or user is in `allowed_users`
2. WHEN a user registers for an event THEN the system SHALL store the registration in Firestore with the user ID and event ID
3. WHEN a user unregisters from an event THEN the system SHALL remove the registration record from Firestore
4. WHEN a user's approval status changes from `false` to `true` THEN the system SHALL immediately allow access to the mobile app without requiring re-login
5. WHEN an event is unpublished by an admin THEN the system SHALL remove it from the mobile app's event list

---

### Requirement 5

**User Story:** As a system administrator, I want to manage the admin panel access, so that only authorized personnel can manage events and approvals.

#### Acceptance Criteria

1. WHEN an admin logs into the web admin panel THEN the system SHALL authenticate using Firebase Authentication with email and password
2. WHEN an unauthenticated user attempts to access the admin panel THEN the system SHALL redirect to the login page
3. WHEN an admin logs out THEN the system SHALL clear the session and redirect to the login page
4. WHEN an admin is logged in THEN the system SHALL display a dashboard with pending approvals, published events, and user management options
5. WHEN an admin session expires THEN the system SHALL require re-authentication before allowing further actions

---

### Requirement 6

**User Story:** As a mobile app user, I want real-time updates about events and approvals, so that I don't miss important information.

#### Acceptance Criteria

1. WHEN an admin publishes a new event THEN the system SHALL update the mobile app in real-time using Firestore listeners
2. WHEN a user's approval status changes THEN the system SHALL notify the mobile app immediately without requiring a manual refresh
3. WHEN an event's allowed users list is modified THEN the system SHALL update the mobile app's event visibility in real-time
4. WHEN a user is removed from an event's allowed list THEN the system SHALL remove the event from their mobile app view immediately
5. WHEN the mobile app loses connection THEN the system SHALL cache the last known state and sync when connection is restored

---

### Requirement 7

**User Story:** As a developer, I want clear data structure and API contracts, so that the mobile app and admin panel can communicate reliably.

#### Acceptance Criteria

1. WHEN data is stored in Firestore THEN the system SHALL use consistent document structure with defined field types (strings, booleans, arrays, timestamps)
2. WHEN the mobile app queries Firestore THEN the system SHALL return data in the same format as the existing API (success, message, data structure)
3. WHEN the admin panel stores event data THEN the system SHALL validate all required fields before writing to Firestore
4. WHEN the mobile app receives Firestore data THEN the system SHALL parse it into Dart models matching the existing API response format
5. WHEN data is serialized to JSON THEN the system SHALL maintain round-trip consistency (serialize then deserialize produces equivalent data)

---

### Requirement 8

**User Story:** As a system administrator, I want to monitor system health and data integrity, so that I can ensure reliable operation.

#### Acceptance Criteria

1. WHEN data is written to Firestore THEN the system SHALL validate data integrity constraints (non-null required fields, valid timestamps, proper array structures)
2. WHEN an admin performs an action THEN the system SHALL log the action with timestamp and admin ID for audit purposes
3. WHEN a user's approval status is changed THEN the system SHALL maintain data consistency across all related documents
4. WHEN an event is deleted THEN the system SHALL remove all associated registrations and references
5. WHEN a user is deleted THEN the system SHALL remove them from all event allowed_users lists and delete their registrations

