# Design Document - Firebase Admin Integration & User Approval System

## Overview

This design document outlines the architecture for integrating Firebase/Firestore into the Edara Hub application while introducing a web-based admin panel. The system maintains the existing Flutter mobile app in the `lib` directory while adding administrative capabilities through a separate web interface. The architecture enables real-time synchronization between the mobile app, admin panel, and Firestore database.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Firebase Project                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Firebase Authentication (Email/Password)            │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Firestore Database                                  │   │
│  │  ├─ users (collection)                               │   │
│  │  ├─ events (collection)                              │   │
│  │  ├─ registrations (collection)                       │   │
│  │  └─ audit_logs (collection)                          │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Firebase Storage (Media files)                      │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
         ▲                              ▲
         │                              │
    ┌────┴──────────────┐      ┌────────┴──────────────┐
    │  Mobile App       │      │  Admin Web Panel      │
    │  (Flutter)        │      │  (React/Vue/etc)      │
    │  lib/             │      │  (Separate repo)      │
    │  ├─ auth/         │      │                       │
    │  ├─ events/       │      │  ├─ auth/             │
    │  └─ main_layout/  │      │  ├─ dashboard/        │
    │                   │      │  ├─ events/           │
    │                   │      │  └─ users/            │
    └───────────────────┘      └───────────────────────┘
```

### Data Flow

1. **User Registration**: Mobile app → Firestore (approved: false)
2. **Admin Approval**: Admin panel → Firestore (approved: true)
3. **Event Publishing**: Admin panel → Firestore (is_published: true)
4. **Event Visibility**: Admin panel → Firestore (allowed_users array)
5. **Real-time Sync**: Firestore listeners → Mobile app & Admin panel
6. **Media Upload**: Admin panel → Firebase Storage → Firestore reference

## Components and Interfaces

### Mobile App Components (Flutter - lib/)

#### 1. Firebase Service Layer
- **FirebaseAuthService**: Handles user authentication with Firestore
- **FirestoreService**: Manages Firestore queries and real-time listeners
- **FirebaseStorageService**: Handles media uploads and downloads

#### 2. Updated Auth Feature (lib/features/auth/)
- **RegisterBloc**: Modified to store user with approved: false
- **LoginBloc**: Modified to check approved status before granting access
- **AuthRepository**: Updated to use Firestore instead of API

#### 3. Updated Events Feature (lib/features/main_layout/)
- **EventsBloc**: Modified to query Firestore with visibility filters
- **EventsRepository**: Updated to use Firestore listeners for real-time updates
- **EventDetailsBloc**: Modified to handle Firestore event data

#### 4. Real-time Listeners
- User approval status listener
- Event publication listener
- Event visibility listener
- Registration listener

### Admin Web Panel Components (Separate Repository)

#### 1. Authentication
- Firebase Authentication integration
- Session management
- Protected routes

#### 2. Dashboard
- Pending user approvals list
- Published events overview
- Quick action buttons

#### 3. User Management
- List of pending registrations
- Approve/Reject functionality
- User details view

#### 4. Event Management
- Create event form
- Edit event form
- Publish/Unpublish toggle
- User selection interface
- Media upload interface

#### 5. Real-time Updates
- Firestore listeners for dashboard updates
- Notification system for admin actions

## Data Models

### Firestore Collections

#### Users Collection
```
users/
├─ {userId}
│  ├─ name: string
│  ├─ employee_id: string (unique)
│  ├─ email: string
│  ├─ phone: string
│  ├─ ip_device: string
│  ├─ approved: boolean (default: false)
│  ├─ status: string ("active" | "inactive")
│  ├─ created_at: timestamp
│  ├─ updated_at: timestamp
│  └─ approved_at: timestamp (null if not approved)
```

#### Events Collection
```
events/
├─ {eventId}
│  ├─ title: string
│  ├─ description: string
│  ├─ category: string ("training" | "meeting" | "social" | "conference")
│  ├─ start_date: timestamp
│  ├─ start_time: string (HH:MM:SS)
│  ├─ end_date: timestamp
│  ├─ end_time: string (HH:MM:SS)
│  ├─ location: string
│  ├─ is_published: boolean (default: false)
│  ├─ visibility: string ("all_users" | "selected_users")
│  ├─ allowed_users: array of userId strings
│  ├─ current_attendees: number (default: 0)
│  ├─ media: object
│  │  ├─ images: array of {id, url, uploaded_at}
│  │  └─ videos: array of {id, url, title, description, size, uploaded_at}
│  ├─ created_at: timestamp
│  ├─ updated_at: timestamp
│  └─ created_by: string (admin userId)
```

#### Registrations Collection
```
registrations/
├─ {registrationId}
│  ├─ user_id: string
│  ├─ event_id: string
│  ├─ registered_at: timestamp
│  ├─ status: string ("confirmed" | "attended" | "cancelled")
│  └─ updated_at: timestamp
```

#### Audit Logs Collection
```
audit_logs/
├─ {logId}
│  ├─ admin_id: string
│  ├─ action: string ("approve_user" | "reject_user" | "publish_event" | "unpublish_event" | "modify_allowed_users" | "delete_event")
│  ├─ target_id: string (userId or eventId)
│  ├─ target_type: string ("user" | "event")
│  ├─ details: object (action-specific details)
│  ├─ timestamp: timestamp
│  └─ ip_address: string
```

### Dart Models (Mobile App)

The mobile app will use Dart models that map to Firestore documents:

```dart
class User {
  final String id;
  final String name;
  final String employeeId;
  final String email;
  final String phone;
  final String ipDevice;
  final bool approved;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt;
}

class Event {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime startDate;
  final String startTime;
  final DateTime endDate;
  final String endTime;
  final String location;
  final bool isPublished;
  final String visibility;
  final List<String> allowedUsers;
  final int currentAttendees;
  final EventMedia media;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
}

class Registration {
  final String id;
  final String userId;
  final String eventId;
  final DateTime registeredAt;
  final String status;
  final DateTime updatedAt;
}
```

## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property 1: User Registration Persistence
*For any* new user registration with valid data, storing the registration in Firestore with `approved: false` status should result in the user document being retrievable with the exact same data and approved status set to false.
**Validates: Requirements 1.1**

### Property 2: Pending User Query Completeness
*For any* set of users in Firestore with mixed approval statuses, querying for unapproved users should return all and only users where `approved: false`.
**Validates: Requirements 1.2**

### Property 3: User Approval Status Update
*For any* user with `approved: false`, calling the approve function should result in the user's `approved` status being set to `true` in Firestore.
**Validates: Requirements 1.3**

### Property 4: User Rejection Deletion
*For any* user in Firestore, calling the reject function should result in the user document being deleted and no longer retrievable.
**Validates: Requirements 1.4**

### Property 5: Unapproved User Access Prevention
*For any* user with `approved: false`, attempting to access protected mobile app resources should be denied.
**Validates: Requirements 1.5**

### Property 6: Event Creation with Required Fields
*For any* event creation with all required fields (title, description, category, dates, times, location), the event should be stored in Firestore with all fields present and retrievable.
**Validates: Requirements 2.1**

### Property 7: Event Publishing Flag
*For any* event, calling the publish function should set `is_published: true` in Firestore and make the event appear in visibility queries.
**Validates: Requirements 2.2**

### Property 8: All Users Event Visibility
*For any* event with `visibility: "all_users"` and `is_published: true`, all approved users should be able to see the event in their mobile app event list.
**Validates: Requirements 2.3**

### Property 9: Selected Users Event Visibility
*For any* event with `visibility: "selected_users"` and a specific `allowed_users` list, only users in that list should be able to see the event in their mobile app.
**Validates: Requirements 2.4**

### Property 10: Media Storage and Referencing
*For any* media file uploaded for an event, the file should be stored in Firebase Storage and the event document should contain a reference to the stored file URL.
**Validates: Requirements 2.5**

### Property 11: Allowed Users Array Persistence
*For any* event with selected users, storing user IDs in the `allowed_users` array should result in those exact user IDs being retrievable from the event document.
**Validates: Requirements 3.2**

### Property 12: Allowed Users List Update
*For any* published event, modifying the `allowed_users` array should update the Firestore document and trigger real-time listeners to update the mobile app.
**Validates: Requirements 3.3**

### Property 13: Non-Allowed User Access Prevention
*For any* user not in the `allowed_users` array of a "selected_users" event, that user should not be able to view or register for the event in the mobile app.
**Validates: Requirements 3.4**

### Property 14: User Removal Cascading Unregistration
*For any* user registered for an event, removing that user from the event's `allowed_users` array should result in their registration being deleted.
**Validates: Requirements 3.5**

### Property 15: Approved User Event Query
*For any* approved user, querying for events should return all events where `is_published: true` and either `visibility: "all_users"` or the user is in `allowed_users`.
**Validates: Requirements 4.1**

### Property 16: Registration Storage
*For any* user registering for an event, a registration document should be created in Firestore with the correct user ID and event ID.
**Validates: Requirements 4.2**

### Property 17: Registration Deletion
*For any* registration, calling the unregister function should delete the registration document from Firestore.
**Validates: Requirements 4.3**

### Property 18: Approval Status Access Grant
*For any* user with `approved: false`, changing their status to `approved: true` should immediately grant access to the mobile app without requiring re-login.
**Validates: Requirements 4.4**

### Property 19: Event Unpublishing Visibility Removal
*For any* published event, setting `is_published: false` should remove the event from the mobile app's event list.
**Validates: Requirements 4.5**

### Property 20: Admin Authentication
*For any* admin with valid Firebase credentials, logging in should authenticate successfully and grant access to the admin panel.
**Validates: Requirements 5.1**

### Property 21: Unauthenticated Admin Access Prevention
*For any* unauthenticated user attempting to access the admin panel, the system should redirect to the login page.
**Validates: Requirements 5.2**

### Property 22: Admin Logout Session Clearing
*For any* authenticated admin, calling the logout function should clear the session and require re-authentication for further access.
**Validates: Requirements 5.3**

### Property 23: Admin Session Expiration
*For any* admin session that expires, attempting to access protected admin panel resources should require re-authentication.
**Validates: Requirements 5.5**

### Property 24: Real-time Event Publication Update
*For any* Firestore listener on the events collection, publishing a new event should trigger the listener and update the mobile app in real-time.
**Validates: Requirements 6.1**

### Property 25: Real-time Approval Status Update
*For any* Firestore listener on a user document, changing the `approved` status should trigger the listener and notify the mobile app immediately.
**Validates: Requirements 6.2**

### Property 26: Real-time Allowed Users Update
*For any* Firestore listener on an event document, modifying the `allowed_users` array should trigger the listener and update the mobile app's event visibility in real-time.
**Validates: Requirements 6.3**

### Property 27: Real-time User Removal from Event
*For any* user removed from an event's `allowed_users` array, the event should disappear from their mobile app view immediately via real-time listener.
**Validates: Requirements 6.4**

### Property 28: Offline Caching and Sync
*For any* mobile app in offline mode, cached event data should be available, and when connection is restored, the app should sync with Firestore and reflect any changes.
**Validates: Requirements 6.5**

### Property 29: Data Type Consistency
*For any* data stored in Firestore, retrieving the data should maintain the same data types (strings remain strings, booleans remain booleans, arrays remain arrays, timestamps remain timestamps).
**Validates: Requirements 7.1**

### Property 30: Response Format Consistency
*For any* Firestore query, the response should be formatted with the same structure as the existing API (success, message, data).
**Validates: Requirements 7.2**

### Property 31: Event Data Validation
*For any* attempt to store incomplete event data (missing required fields), the system should reject the write and prevent the invalid data from being stored.
**Validates: Requirements 7.3**

### Property 32: Firestore to Dart Model Parsing
*For any* Firestore document, parsing it into a Dart model should produce an object with all fields correctly mapped and typed.
**Validates: Requirements 7.4**

### Property 33: Serialization Round-trip Consistency
*For any* data serialized to JSON and then deserialized, the resulting data should be equivalent to the original data.
**Validates: Requirements 7.5**

### Property 34: Data Integrity Validation
*For any* write to Firestore, the system should validate data integrity constraints (non-null required fields, valid timestamps, proper array structures) before writing.
**Validates: Requirements 8.1**

### Property 35: Audit Logging
*For any* admin action, a log entry should be created in the audit_logs collection with the correct admin ID, action type, target ID, and timestamp.
**Validates: Requirements 8.2**

### Property 36: Approval Status Consistency
*For any* user approval status change, all related documents (registrations, event allowed_users lists) should remain consistent.
**Validates: Requirements 8.3**

### Property 37: Event Deletion Cascading
*For any* event deletion, all associated registration documents should be deleted.
**Validates: Requirements 8.4**

### Property 38: User Deletion Cascading
*For any* user deletion, the user should be removed from all event `allowed_users` arrays and all their registration documents should be deleted.
**Validates: Requirements 8.5**

## Error Handling

### Mobile App Error Handling
- **Unapproved User**: Display message "Your account is pending approval. Please wait for admin confirmation."
- **Firestore Connection Error**: Display cached data if available, show retry button
- **Authentication Error**: Redirect to login with error message
- **Invalid Event Access**: Display "You don't have access to this event"
- **Registration Failure**: Display error message and retry option

### Admin Panel Error Handling
- **Authentication Failure**: Display "Invalid credentials" message
- **Session Expiration**: Redirect to login with "Session expired" message
- **Validation Error**: Display field-specific error messages
- **Firestore Write Error**: Display error message and retry option
- **Media Upload Error**: Display error message and allow retry

### Data Validation
- Required fields must be non-null
- Timestamps must be valid ISO format
- Arrays must contain valid document IDs
- Email must be valid format
- Phone must be valid format

## Testing Strategy

### Unit Testing
- Test Firestore service methods in isolation
- Test Dart model parsing and serialization
- Test validation functions
- Test access control logic
- Test data transformation functions

### Property-Based Testing
- Use `fast-check` (JavaScript) for admin panel tests
- Use `quickcheck` or similar for Dart mobile app tests
- Generate random valid data and verify properties hold
- Test with 100+ iterations per property
- Each property test should be tagged with the property number and requirement reference

### Integration Testing
- Test mobile app → Firestore → Admin panel flow
- Test real-time listener updates
- Test offline caching and sync
- Test cascading deletions
- Test concurrent updates

### Test Coverage
- All correctness properties must have corresponding property-based tests
- Critical paths must have integration tests
- Error conditions must be tested
- Edge cases (empty arrays, null values, boundary timestamps) must be tested

