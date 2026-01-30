# Implementation Plan - Firebase Admin Integration & User Approval System

## Overview

This implementation plan breaks down the Firebase integration and admin panel development into discrete, manageable coding tasks. Tasks are sequenced to validate core functionality early and build incrementally. The mobile app remains in the `lib` directory while Firebase services are integrated. The admin panel is a separate web application.

---

## Mobile App - Firebase Integration Tasks

- [x] 1. Set up Firebase in Flutter mobile app










  - Add Firebase dependencies to pubspec.yaml (firebase_core, cloud_firestore, firebase_auth, firebase_storage)
  - Initialize Firebase in main.dart
  - Configure Firebase project credentials
  - _Requirements: 1.1, 2.1, 4.1_

- [x] 2. Create Firebase service layer





  - [x] 2.1 Create FirebaseAuthService for authentication


    - Implement sign up with email/password
    - Implement login with email/password
    - Implement logout
    - Implement get current user
    - _Requirements: 1.1, 5.1_
  
  - [x] 2.2 Write property test for authentication


    - **Feature: firebase-admin-integration, Property 20: Admin Authentication**
    - **Validates: Requirements 5.1**
  

  - [x] 2.3 Create FirestoreService for database operations

    - Implement user document creation
    - Implement user document queries
    - Implement event document queries with filters
    - Implement registration document operations
    - _Requirements: 1.1, 2.1, 4.1_
  


  - [x] 2.4 Write property test for Firestore operations

    - **Feature: firebase-admin-integration, Property 1: User Registration Persistence**


    - **Validates: Requirements 1.1**
  
  - [x] 2.5 Create FirebaseStorageService for media uploads

    - Implement image upload to Firebase Storage
    - Implement video upload to Firebase Storage
    - Implement file URL retrieval
    - _Requirements: 2.5_
  
  - [x] 2.6 Write property test for media storage


    - **Feature: firebase-admin-integration, Property 10: Media Storage and Referencing**
    - **Validates: Requirements 2.5**

- [ ] 3. Update authentication feature (lib/features/auth/)
  - [ ] 3.1 Modify RegisterBloc to use Firebase
    - Update to call FirebaseAuthService.signUp
    - Store user in Firestore with approved: false
    - Handle registration response
    - _Requirements: 1.1_
  
  - [ ] 3.2 Write property test for user registration
    - **Feature: firebase-admin-integration, Property 1: User Registration Persistence**
    - **Validates: Requirements 1.1**
  
  - [ ] 3.3 Modify LoginBloc to check approval status
    - Update to call FirebaseAuthService.login
    - Query Firestore for user approval status
    - Prevent login if approved: false
    - Display approval pending message
    - _Requirements: 1.5, 4.4_
  
  - [ ] 3.4 Write property test for approval status check
    - **Feature: firebase-admin-integration, Property 5: Unapproved User Access Prevention**
    - **Validates: Requirements 1.5**
  
  - [ ] 3.5 Update AuthRepository to use Firestore
    - Replace API calls with Firestore queries
    - Implement real-time listener for approval status changes
    - _Requirements: 1.5, 6.2_
  
  - [ ] 3.6 Write property test for real-time approval updates
    - **Feature: firebase-admin-integration, Property 25: Real-time Approval Status Update**
    - **Validates: Requirements 6.2**

- [ ] 4. Update events feature (lib/features/main_layout/)
  - [ ] 4.1 Modify EventsBloc to query Firestore
    - Update to query events from Firestore
    - Filter by is_published: true
    - Filter by visibility (all_users or user in allowed_users)
    - Handle pagination
    - _Requirements: 4.1_
  
  - [ ] 4.2 Write property test for event visibility filtering
    - **Feature: firebase-admin-integration, Property 8: All Users Event Visibility**
    - **Validates: Requirements 2.3**
  
  - [ ] 4.3 Modify EventsRepository to use Firestore listeners
    - Implement real-time listener for events collection
    - Update BLoC when events change
    - Handle offline caching
    - _Requirements: 6.1, 6.3, 6.5_
  
  - [ ] 4.4 Write property test for real-time event updates
    - **Feature: firebase-admin-integration, Property 24: Real-time Event Publication Update**
    - **Validates: Requirements 6.1**
  
  - [ ] 4.5 Update EventDetailsBloc for Firestore data
    - Query event details from Firestore
    - Handle selected_users visibility check
    - Implement registration functionality
    - _Requirements: 3.4, 4.2_
  
  - [ ] 4.6 Write property test for selected users visibility
    - **Feature: firebase-admin-integration, Property 9: Selected Users Event Visibility**
    - **Validates: Requirements 2.4**

- [ ] 5. Implement registration functionality
  - [ ] 5.1 Create registration service
    - Implement register for event (create registration document)
    - Implement unregister from event (delete registration document)
    - Update event current_attendees count
    - _Requirements: 4.2, 4.3_
  
  - [ ] 5.2 Write property test for registration storage
    - **Feature: firebase-admin-integration, Property 16: Registration Storage**
    - **Validates: Requirements 4.2**
  
  - [ ] 5.3 Write property test for registration deletion
    - **Feature: firebase-admin-integration, Property 17: Registration Deletion**
    - **Validates: Requirements 4.3**

- [ ] 6. Implement real-time listeners and offline support
  - [ ] 6.1 Create listener manager for real-time updates
    - Implement listeners for user approval status
    - Implement listeners for event changes
    - Implement listeners for registration changes
    - Handle listener cleanup
    - _Requirements: 6.1, 6.2, 6.3, 6.4_
  
  - [ ] 6.2 Implement offline caching
    - Enable Firestore offline persistence
    - Cache event data locally
    - Sync when connection restored
    - _Requirements: 6.5_
  
  - [ ] 6.3 Write property test for offline caching
    - **Feature: firebase-admin-integration, Property 28: Offline Caching and Sync**
    - **Validates: Requirements 6.5**

- [ ] 7. Update Dart models for Firestore compatibility
  - [ ] 7.1 Create Dart models matching Firestore structure
    - User model with all fields
    - Event model with all fields
    - Registration model
    - EventMedia model
    - _Requirements: 7.4_
  
  - [ ] 7.2 Implement serialization/deserialization
    - fromJson methods for all models
    - toJson methods for all models
    - Handle timestamp conversion
    - _Requirements: 7.4, 7.5_
  
  - [ ] 7.3 Write property test for model serialization
    - **Feature: firebase-admin-integration, Property 33: Serialization Round-trip Consistency**
    - **Validates: Requirements 7.5**

- [ ] 8. Checkpoint - Ensure all mobile app tests pass
  - Ensure all tests pass, ask the user if questions arise.

---

## Admin Web Panel - New Application

- [ ] 9. Set up admin web panel project
  - Create new web project (React/Vue/Angular - choose based on preference)
  - Add Firebase dependencies (firebase, firebaseui)
  - Configure Firebase project credentials
  - Set up project structure (auth, dashboard, events, users folders)
  - _Requirements: 5.1_

- [ ] 10. Implement admin authentication
  - [ ] 10.1 Create Firebase authentication service
    - Implement login with email/password
    - Implement logout
    - Implement session management
    - _Requirements: 5.1, 5.3_
  
  - [ ] 10.2 Write property test for admin authentication
    - **Feature: firebase-admin-integration, Property 20: Admin Authentication**
    - **Validates: Requirements 5.1**
  
  - [ ] 10.3 Create protected routes
    - Implement route guards for authenticated users
    - Redirect unauthenticated users to login
    - Handle session expiration
    - _Requirements: 5.2, 5.5_
  
  - [ ] 10.4 Write property test for access prevention
    - **Feature: firebase-admin-integration, Property 21: Unauthenticated Admin Access Prevention**
    - **Validates: Requirements 5.2**

- [ ] 11. Implement user management dashboard
  - [ ] 11.1 Create pending approvals list component
    - Query Firestore for users with approved: false
    - Display user details (name, employee_id, email, phone, registration date)
    - _Requirements: 1.2_
  
  - [ ] 11.2 Write property test for pending user query
    - **Feature: firebase-admin-integration, Property 2: Pending User Query Completeness**
    - **Validates: Requirements 1.2**
  
  - [ ] 11.3 Implement approve user functionality
    - Create approve button for each pending user
    - Update user approved: true in Firestore
    - Log action to audit_logs
    - _Requirements: 1.3, 8.2_
  
  - [ ] 11.4 Write property test for user approval
    - **Feature: firebase-admin-integration, Property 3: User Approval Status Update**
    - **Validates: Requirements 1.3**
  
  - [ ] 11.5 Implement reject user functionality
    - Create reject button for each pending user
    - Delete user document from Firestore
    - Log action to audit_logs
    - _Requirements: 1.4, 8.2_
  
  - [ ] 11.6 Write property test for user rejection
    - **Feature: firebase-admin-integration, Property 4: User Rejection Deletion**
    - **Validates: Requirements 1.4**

- [ ] 12. Implement event management dashboard
  - [ ] 12.1 Create event list component
    - Query Firestore for all events
    - Display event details (title, category, dates, is_published status)
    - _Requirements: 2.1_
  
  - [ ] 12.2 Create event creation form
    - Form fields for title, description, category, dates, times, location
    - Validate all required fields
    - Store event in Firestore with is_published: false
    - _Requirements: 2.1, 7.3_
  
  - [ ] 12.3 Write property test for event creation
    - **Feature: firebase-admin-integration, Property 6: Event Creation with Required Fields**
    - **Validates: Requirements 2.1**
  
  - [ ] 12.4 Create event editing form
    - Load event data from Firestore
    - Allow editing all event fields
    - Update event document in Firestore
    - _Requirements: 2.1_
  
  - [ ] 12.5 Implement publish/unpublish toggle
    - Create toggle button for is_published status
    - Update event in Firestore
    - Log action to audit_logs
    - _Requirements: 2.2, 4.5, 8.2_
  
  - [ ] 12.6 Write property test for event publishing
    - **Feature: firebase-admin-integration, Property 7: Event Publishing Flag**
    - **Validates: Requirements 2.2**

- [ ] 13. Implement event visibility management
  - [ ] 13.1 Create visibility selector component
    - Radio buttons for "all_users" or "selected_users"
    - Show/hide user selection based on choice
    - _Requirements: 2.3, 2.4_
  
  - [ ] 13.2 Create user selection interface
    - List of all approved users with checkboxes
    - Store selected user IDs in allowed_users array
    - _Requirements: 3.2_
  
  - [ ] 13.3 Write property test for allowed users storage
    - **Feature: firebase-admin-integration, Property 11: Allowed Users Array Persistence**
    - **Validates: Requirements 3.2**
  
  - [ ] 13.4 Implement allowed users list modification
    - Allow editing allowed_users for published events
    - Update Firestore document
    - Handle cascading unregistration if user removed
    - Log action to audit_logs
    - _Requirements: 3.3, 3.5, 8.2_
  
  - [ ] 13.5 Write property test for allowed users update
    - **Feature: firebase-admin-integration, Property 12: Allowed Users List Update**
    - **Validates: Requirements 3.3**
  
  - [ ] 13.6 Write property test for cascading unregistration
    - **Feature: firebase-admin-integration, Property 14: User Removal Cascading Unregistration**
    - **Validates: Requirements 3.5**

- [ ] 14. Implement media upload functionality
  - [ ] 14.1 Create media upload component
    - File input for images and videos
    - Upload to Firebase Storage
    - Store file references in event document
    - _Requirements: 2.5_
  
  - [ ] 14.2 Write property test for media storage
    - **Feature: firebase-admin-integration, Property 10: Media Storage and Referencing**
    - **Validates: Requirements 2.5**
  
  - [ ] 14.3 Create media preview component
    - Display uploaded images and videos
    - Allow deletion of media files
    - _Requirements: 2.5_

- [ ] 15. Implement real-time dashboard updates
  - [ ] 15.1 Create Firestore listener for dashboard
    - Listen to users collection for new pending approvals
    - Listen to events collection for changes
    - Update dashboard in real-time
    - _Requirements: 6.1, 6.2_
  
  - [ ] 15.2 Implement notification system
    - Show notifications for new pending approvals
    - Show notifications for admin actions
    - _Requirements: 1.4_

- [ ] 16. Implement audit logging
  - [ ] 16.1 Create audit log service
    - Log all admin actions (approve, reject, publish, modify users)
    - Store in audit_logs collection with admin ID, action, target, timestamp
    - _Requirements: 8.2_
  
  - [ ] 16.2 Write property test for audit logging
    - **Feature: firebase-admin-integration, Property 35: Audit Logging**
    - **Validates: Requirements 8.2**
  
  - [ ] 16.3 Create audit log viewer (optional)
    - Display audit logs in admin panel
    - Filter by action type, date range, admin
    - _Requirements: 8.2_

- [ ] 17. Implement data validation and error handling
  - [ ] 17.1 Create validation service
    - Validate required fields before Firestore writes
    - Validate data types and formats
    - _Requirements: 7.3, 8.1_
  
  - [ ] 17.2 Write property test for data validation
    - **Feature: firebase-admin-integration, Property 31: Event Data Validation**
    - **Validates: Requirements 7.3**
  
  - [ ] 17.3 Implement error handling
    - Display user-friendly error messages
    - Implement retry logic for failed operations
    - _Requirements: 7.3, 8.1_

- [ ] 18. Checkpoint - Ensure all admin panel tests pass
  - Ensure all tests pass, ask the user if questions arise.

---

## Data Integrity and Consistency Tasks

- [ ] 19. Implement cascading operations
  - [ ] 19.1 Implement user deletion cascading
    - When user deleted, remove from all event allowed_users arrays
    - Delete all user registrations
    - Log action to audit_logs
    - _Requirements: 8.5_
  
  - [ ] 19.2 Write property test for user deletion cascading
    - **Feature: firebase-admin-integration, Property 38: User Deletion Cascading**
    - **Validates: Requirements 8.5**
  
  - [ ] 19.3 Implement event deletion cascading
    - When event deleted, delete all associated registrations
    - Log action to audit_logs
    - _Requirements: 8.4_
  
  - [ ] 19.4 Write property test for event deletion cascading
    - **Feature: firebase-admin-integration, Property 37: Event Deletion Cascading**
    - **Validates: Requirements 8.4**

- [ ] 20. Implement data consistency checks
  - [ ] 20.1 Create consistency validation service
    - Verify approval status consistency
    - Verify event visibility consistency
    - Verify registration consistency
    - _Requirements: 8.3_
  
  - [ ] 20.2 Write property test for approval status consistency
    - **Feature: firebase-admin-integration, Property 36: Approval Status Consistency**
    - **Validates: Requirements 8.3**

- [ ] 21. Implement data type validation
  - [ ] 21.1 Create type validation service
    - Validate all Firestore data maintains correct types
    - Validate timestamps are valid ISO format
    - Validate arrays contain valid IDs
    - _Requirements: 7.1, 8.1_
  
  - [ ] 21.2 Write property test for data type consistency
    - **Feature: firebase-admin-integration, Property 29: Data Type Consistency**
    - **Validates: Requirements 7.1**

- [ ] 22. Implement response format consistency
  - [ ] 22.1 Create response formatter
    - Format all Firestore responses with success, message, data structure
    - Match existing API response format
    - _Requirements: 7.2_
  
  - [ ] 22.2 Write property test for response format
    - **Feature: firebase-admin-integration, Property 30: Response Format Consistency**
    - **Validates: Requirements 7.2**

- [ ] 23. Checkpoint - Ensure all data integrity tests pass
  - Ensure all tests pass, ask the user if questions arise.

---

## Integration and Final Testing Tasks

- [ ] 24. Integration testing - Mobile app to Firestore
  - [ ] 24.1 Test user registration flow end-to-end
    - Register user in mobile app
    - Verify user appears in admin panel pending approvals
    - Approve user in admin panel
    - Verify user can login to mobile app
    - _Requirements: 1.1, 1.2, 1.3, 1.5_
  
  - [ ] 24.2 Test event visibility flow end-to-end
    - Create event in admin panel with selected_users
    - Select specific users
    - Verify only selected users see event in mobile app
    - Modify allowed_users list
    - Verify mobile app updates in real-time
    - _Requirements: 2.1, 2.4, 3.2, 3.3, 6.3_
  
  - [ ] 24.3 Test event registration flow end-to-end
    - User registers for event in mobile app
    - Verify registration appears in Firestore
    - User unregisters
    - Verify registration deleted
    - _Requirements: 4.2, 4.3_

- [ ] 25. Integration testing - Admin panel to Firestore
  - [ ] 25.1 Test admin authentication flow
    - Login to admin panel
    - Verify session created
    - Logout
    - Verify session cleared
    - _Requirements: 5.1, 5.3_
  
  - [ ] 25.2 Test user approval workflow
    - Create new user registration
    - Approve in admin panel
    - Verify user can access mobile app
    - _Requirements: 1.1, 1.3, 1.5_

- [ ] 26. Final checkpoint - All systems integration
  - Ensure all tests pass, ask the user if questions arise.

---

## Notes

- All property-based tests should run with minimum 100 iterations
- Each property test should be tagged with the property number and requirement reference
- Mobile app tests use Dart testing framework (test package)
- Admin panel tests use appropriate JavaScript testing framework (Jest, Vitest, etc.)
- Integration tests should cover critical user workflows
- Offline caching tests should simulate network disconnection
- Real-time listener tests should verify listener triggers and data updates

