# Design Summary: Kigali Services & Places Directory

## 1. Firestore Database Design

### Schema Overview

The Firestore database consists of two main collections: `users` and `listings`.

#### Collection: `users`
**Purpose**: Store user profile information and preferences
**Document ID**: Firebase UID (auto-generated)

**Fields**:
- `email` (string): User's email address
- `displayName` (string): User's full name
- `photoUrl` (string, optional): Profile picture URL
- `emailVerified` (boolean): Email verification status
- `notificationsEnabled` (boolean): Notification preference (default: true)
- `createdAt` (timestamp): Account creation date

**Indexes**: None required for this implementation

#### Collection: `listings`
**Purpose**: Store all service and place listings
**Document ID**: Auto-generated Firebase ID

**Fields**:
- `name` (string): Service/place name
- `category` (string): Service category (Hospital, Restaurant, Park, etc.)
- `address` (string): Full address
- `contactNumber` (string): Phone number
- `description` (string): Detailed description
- `latitude` (double): Geographic latitude
- `longitude` (double): Geographic longitude
- `createdBy` (string): Creator's UID (document reference)
- `timestamp` (timestamp): Creation/update time
- `imageUrl` (string, optional): Image URL for future use

**Indexes**: 
- `createdBy` + `timestamp` (for efficient user listing queries)
- `category` + `timestamp` (for category filtering)

### Data Relationships

```
users (1) ←→ (*) listings
├─ One user can create multiple listings
├─ Each listing has a createdBy field containing the user's UID
└─ Enables enforcement of edit/delete permissions
```

### Data Persistence Model

**Read Operations**:
- All listings: `collection('listings').orderBy('timestamp', descending: true)`
- User listings: `collection('listings').where('createdBy', isEqualTo: uid)`
- By category: `collection('listings').where('category', isEqualTo: category)`
- Search: Client-side filtering on all listings

**Write Operations**:
- Create: Add new document to `listings` collection
- Update: Update existing document fields
- Delete: Remove document from `listings` collection

**Real-time Synchronization**:
- Uses Firestore real-time listeners (snapshots)
- Automatic UI updates when data changes
- Subscriber pattern ensures data consistency

## 2. State Management Implementation

### Architecture Overview

The application uses the Provider pattern with a service-repository pattern:

```
UI Components
    ↓
Provider Controllers (AuthProvider, ListingProvider)
    ↓
Service Classes (AuthService, FirestoreService)
    ↓
Firebase SDK
    ↓
Firebase Backend
```

### AuthProvider Structure

**Responsibilities**:
- Manage authentication state
- Store current user information
- Handle user profile data
- Manage loading and error states

**Key Methods**:
```dart
signUp()                          // Create new user account
logIn()                           // Login existing user
signOut()                         // Logout current user
resendEmailVerification()         // Resend verification email
checkEmailVerificationStatus()    // Check verification
updateUserProfile()               // Update profile info
updateNotificationPreference()    // Toggle notifications
```

**State Variables**:
- `_currentUser`: Firebase User object
- `_userProfile`: UserModel from Firestore
- `_isLoading`: Loading state
- `_error`: Error message
- `_isEmailVerified`: Email verification status

### ListingProvider Structure

**Responsibilities**:
- Manage listings list state
- Handle search and filtering
- Manage CRUD operations
- Handle loading and error states

**Key Methods**:
```dart
subscribeToAllListings()         // Real-time all listings
subscribeToUserListings(uid)     // Real-time user listings
createListing()                  // Add new listing
updateListing()                  // Modify listing
deleteListing()                  // Remove listing
searchListings(query)            // Search listings
filterByCategory(category)       // Filter by category
```

**State Variables**:
- `_allListings`: List of all listings
- `_userListings`: User's created listings
- `_filteredListings`: Search/filtered results
- `_selectedCategory`: Current filter category
- `_searchQuery`: Current search query
- `_isLoading`: Loading state
- `_error`: Error message

### Data Flow Architecture

**Example Flow: Creating a Listing**

```
1. User fills AddListingScreen form
2. Provider method called: listingProvider.createListing()
3. ListingProvider validates and calls service
4. FirestoreService adds document to Firestore
5. Firestore returns document ID
6. Real-time listener updates _userListings
7. UI Consumer rebuilds with updated list
8. Success message shown to user
```

**Example Flow: Search & Filter**

```
1. User types in search box (DirectoryScreen)
2. listingProvider.searchListings(query) called
3. ListingProvider streams filtered results
4. Client-side filtering applied to _allListings
5. _filteredListings updated with matches
6. UI Consumer rebuilds with filtered list
7. Results update as user types
```

## 3. Design Trade-offs & Decisions

### Trade-off 1: Client-side vs Server-side Filtering

**Decision**: Client-side filtering for search

**Rationale**:
- ✅ **Pros**: 
  - No Firestore read operations for each keystroke
  - Instant results for better UX
  - Works offline-ready (future enhancement)
- ❌ **Cons**: 
  - Limited to loaded data
  - Not scalable for 100k+ listings

**Future Alternative**: Move to server-side queries when data grows

### Trade-off 2: Real-time vs On-demand Updates

**Decision**: Real-time Firestore listeners

**Rationale**:
- ✅ **Pros**:
  - Automatic UI updates
  - Live collaboration ready
  - No manual refresh needed
  - Better UX
- ❌ **Cons**:
  - Higher Firestore costs
  - Network always listening
  - Requires connection

**Alternative**: Could implement manual refresh with `pull-to-refresh`

### Trade-off 3: Email Verification Enforcement

**Decision**: Require email verification before access

**Rationale**:
- ✅ **Pros**:
  - Prevents spam accounts
  - Better data quality
  - Security enhancement
- ❌ **Cons**:
  - Adds friction to onboarding
  - Users might not verify

**Implementation**: Email sent at signup, checked at login

### Trade-off 4: Service Layer Pattern

**Decision**: Separate service layer from UI

**Rationale**:
- ✅ **Pros**:
  - Testable code
  - Reusable logic
  - Easier maintenance
  - Clear separation of concerns
- ❌ **Cons**:
  - More files/boilerplate
  - Slightly more complex

### Trade-off 5: Provider vs Other Solutions

**Decision**: Provider for state management

**Rationale**:
- ✅ **Pros**:
  - Lightweight and simple
  - Good performance
  - Easy to debug
  - Good for small-medium apps
- ❌ **Cons**:
  - Less powerful than BLoC
  - Limited middleware support
  - Performance degrades with large state

**Considered Alternatives**: BLoC, Riverpod, GetX

## 4. Technical Challenges & Solutions

### Challenge 1: Real-time State Synchronization

**Problem**: Multiple screens need to reflect listing changes instantly

**Solution**: 
- Firestore listeners in providers
- Consumer widgets rebuild on state change
- Separate subscriptions for all/user listings

### Challenge 2: User-specific Data Access

**Problem**: Users should only edit/delete their own listings

**Solution**:
- Store `createdBy` UID with each listing
- Check UID before edit/delete operations
- Future: Firestore security rules enforcement

### Challenge 3: Search Performance

**Problem**: Searching through 1000+ listings could be slow

**Solution**:
- Client-side filtering with optimized List.where()
- Local caching in Provider
- Future: Firestore full-text search

### Challenge 4: Error Handling

**Problem**: Firebase operations can fail silently

**Solution**:
- Try-catch blocks in all service methods
- Error messages displayed in UI
- Error state management in providers
- User-friendly error messages

### Challenge 5: Memory Management

**Problem**: Large lists could consume too much memory

**Solution**:
- Subscribe only to needed data
- Dispose of listeners properly
- Pagination-ready implementation
- Lazy loading for future

## 5. Security Considerations

### Authentication Security
- Firebase Authentication handles credential security
- Email verification prevents spam
- Password requirements enforced by Firebase
- Session tokens auto-managed

### Data Security
### Firestore Rules Structure (Recommended)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Anyone can read listings, only creator can edit/delete
    match /listings/{document=**} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                      request.resource.data.createdBy == request.auth.uid;
      allow update, delete: if request.auth.uid == resource.data.createdBy;
    }
  }
}
```

## 6. Performance Metrics

### Database Indexes
- Composite index: `(createdBy, timestamp)` for user listings
- Composite index: `(category, timestamp)` for category filter

### Expected Performance
- Load all listings: ~500ms (1000 documents)
- Search 1000 listings: ~100ms (client-side)
- Create listing: ~1000ms (write + listener update)
- List refresh: Real-time (< 100ms)

## 7. Future Scalability

### Phase 1 (Current)
- Single database
- Client-side filtering
- Real-time listeners

### Phase 2 (Enhancement)
- Add Firestore security rules
- Implement pagination
- Add server-side search
- Image upload to Storage

### Phase 3 (Growth)
- Regional database sharding
- Cloud Functions for complex ops
- Full-text search with Algolia
- Admin dashboard

### Phase 4 (Scale)
- Multi-region deployment
- Analytics with BigQuery
- ML-based recommendations
- Advanced caching layer

## 8. Testing Strategy

### Unit Tests
- Service methods
- Provider state changes
- Model serialization

### Widget Tests
- Screen rendering
- User interactions
- Form validation

### Integration Tests
- Full authentication flow
- CRUD operations
- Search functionality

### Manual Testing
- Firebase integration
- Real-time updates
- Network failures
- Offline behavior

## 9. Deployment Considerations

### Android
- Minimum API: 21
- Target API: 34
- Sign APK with release key
- Google Play Store submission

### iOS
- Minimum iOS: 11.0
- Target iOS: 14.0+
- Sign with Apple Developer certificate
- App Store submission

### Firebase Setup
- Configure SHA-1 for Android
- Configure Bundle ID for iOS
- Set authorized domains
- Configure OAuth consent screen

---

**Document Version**: 1.0  
**Last Updated**: March 2026  
**Status**: Completed Application
