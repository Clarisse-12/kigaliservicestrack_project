# Kigali Services & Places Directory

A comprehensive Flutter mobile application that helps Kigali residents locate and navigate to essential public services and leisure locations across the city.

## Features

### ✅ Core Features
- **User Authentication**
  - Email/Password registration and login
  - Email verification requirement before app access
  - Secure session management
  - User profile management

- **Location Listings (CRUD)**
  - Create new service/place listings
  - View all listings in a shared directory
  - Edit your own listings
  - Delete your listings
  - Real-time updates via Firestore

- **Search & Filtering**
  - Search listings by name, address, or description
  - Filter by category (Hospital, Restaurant, Park, etc.)
  - Dynamic filtering with instant results
  - Maintains search state across navigation

- **Directory Screen**
  - Browse all available services
  - Category-based filtering
  - Detailed listing cards with contact info
  - Search functionality

- **Map Integration**
  - View all listings on an interactive map view
  - Display geographic coordinates
  - Quick navigation buttons
  - Distance calculations

- **My Listings Screen**
  - View only your created listings
  - Edit listings with updated information
  - Delete unwanted listings
  - Quick access from bottom navigation

- **Settings Screen**
  - User profile display
  - Email verification status
  - Notification preferences toggle
  - Account management
  - Sign out functionality

- **Navigation**
  - Bottom navigation bar with 4 main screens
  - Smooth transitions between screens
  - Deep linking support
  - State preservation

## Technical Architecture

### Frontend Architecture
- **State Management**: Provider pattern
- **Navigation**: Named routes with arguments
- **Responsive Design**: Mobile-first approach
- **Theme**: Custom Material Design 3 theme with Kigali blue primary color (#1F3A93)

### Backend Architecture
- **Authentication**: Firebase Authentication
- **Database**: Cloud Firestore
- **API Structure**: RESTful via Firebase
- **Real-time Updates**: Firestore listeners/streams

## Firestore Database Structure

### Collections

#### `users`
User profiles collection storing user information:
```json
{
  "uid": "string (document ID)",
  "email": "string",
  "displayName": "string",
  "photoUrl": "string (optional)",
  "emailVerified": "boolean",
  "notificationsEnabled": "boolean",
  "createdAt": "timestamp"
}
```

#### `listings`
Location/service listings collection:
```json
{
  "id": "string (document ID)",
  "name": "string",
  "category": "string (enum: Hospital, Police Station, Library, etc.)",
  "address": "string",
  "contactNumber": "string",
  "description": "string",
  "latitude": "double",
  "longitude": "double",
  "createdBy": "string (user UID)",
  "timestamp": "timestamp",
  "imageUrl": "string (optional)"
}
```

## Project Structure

```
kigaliservicestrack_project/
├── android/                          # Android platform files
│   ├── app/
│   │   ├── src/
│   │   ├── build.gradle.kts
│   │   └── google-services.json     # Firebase Android config
│   ├── gradle/
│   └── build.gradle.kts
│
├── ios/                              # iOS platform files
│   ├── Runner/
│   ├── Runner.xcodeproj/
│   └── Runner.xcworkspace/
│
├── lib/                              # Main application code
│   ├── models/                       # Data models
│   │   ├── listing_model.dart       # Listing entity with CRUD methods
│   │   └── user_model.dart          # User profile entity
│   │
│   ├── services/                     # Business logic layer
│   │   ├── auth_service.dart        # Firebase Authentication service
│   │   └── firestore_service.dart   # Firestore database operations
│   │
│   ├── providers/                    # State management (Provider pattern)
│   │   ├── auth_provider.dart       # Authentication state management
│   │   └── listing_provider.dart    # Listings state management
│   │
│   ├── screens/                      # UI screens
│   │   ├── login_screen.dart        # User login
│   │   ├── signup_screen.dart       # User registration
│   │   ├── home_screen.dart         # Main navigation hub
│   │   ├── directory_screen.dart    # Browse all listings
│   │   ├── map_screen.dart          # Map view of listings
│   │   ├── my_listings_screen.dart  # User's own listings
│   │   ├── settings_screen.dart     # User settings & profile
│   │   ├── detail_screen.dart       # Listing details view
│   │   ├── add_listing_screen.dart  # Create new listing
│   │   ├── edit_listing_screen.dart # Edit existing listing
│   │   └── directions_map_screen.dart # Navigation directions
│   │
│   ├── firebase_options.dart         # Firebase configuration
│   └── main.dart                     # App entry point
│
├── linux/                            # Linux platform files
├── macos/                            # macOS platform files
├── web/                              # Web platform files
├── windows/                          # Windows platform files
│
├── test/                             # Unit and widget tests
│   └── widget_test.dart
│
├── .gitignore                        # Git ignore rules
├── analysis_options.yaml             # Dart analyzer configuration
├── devtools_options.yaml             # DevTools configuration
├── firebase.json                     # Firebase project config
├── pubspec.yaml                      # Dependencies & metadata
├── pubspec.lock                      # Locked dependency versions
└── README.md                         # Project documentation
```

## Installation & Setup

### Prerequisites
- Flutter SDK >= 3.11.0
- A Firebase project configured for Flutter

### Firebase Setup
1. Create a Firebase project
2. Enable Authentication (Email/Password)
3. Enable Cloud Firestore
4. Download Firebase configuration
5. Update firebase_options.dart

### Running the App
```bash
flutter pub get
flutter run
```

## State Management

The application uses the Provider pattern for state management with two main providers:

1. **AuthProvider**: Manages authentication state and user profile
2. **ListingProvider**: Manages listings, search, and filtering

All Firestore operations are handled through dedicated service layers and exposed to the UI via these providers.

## Navigation Routes

```
/login          → Login screen
/signup         → Sign up screen
/home           → Main home screen
/detail         → Listing detail view
/add-listing    → Create new listing
/edit-listing   → Edit existing listing
```

## Available Categories

- Hospital
- Police Station
- Library
- Utility Office
- Restaurant
- Café
- Park
- Tourist Attraction
- School
- Bank
- Market

## Color Scheme

- **Primary**: #1F3A93 (Kigali Blue)
- **Background**: #F5F5F5 (Light Gray)
- **Success**: Green
- **Error**: Red

## Dependencies & Packages

### Core Dependencies
```yaml
flutter:
  sdk: flutter

# State Management
provider: ^6.1.5                    # Provider pattern for state management

# Firebase Backend
firebase_core: ^3.0.0               # Firebase core functionality
firebase_auth: ^5.0.0               # User authentication
cloud_firestore: ^5.5.0             # NoSQL cloud database
firebase_storage: ^12.0.0           # Cloud file storage

# Maps & Location
flutter_map: ^6.1.0                 # Interactive map widget
latlong2: ^0.9.0                    # Latitude/longitude calculations
geolocator: ^11.0.0                 # Device location services
google_maps_flutter: ^2.6.0         # Google Maps integration

# Utilities
url_launcher: ^6.2.5                # Launch URLs, phone, email
go_router: ^14.0.0                  # Advanced routing (optional)
intl: ^0.20.0                       # Internationalization & formatting
cupertino_icons: ^1.0.8             # iOS-style icons
```

### Dev Dependencies
```yaml
flutter_test:
  sdk: flutter
flutter_lints: ^6.0.0               # Recommended linting rules
```

## Technologies Used

### Frontend
- **Framework**: Flutter 3.11.0+
- **Language**: Dart 3.11.0+
- **UI**: Material Design 3
- **State Management**: Provider pattern
- **Navigation**: Named routes with arguments

### Backend & Services
- **Authentication**: Firebase Authentication (Email/Password)
- **Database**: Cloud Firestore (NoSQL)
- **Storage**: Firebase Storage (for images)
- **Real-time Updates**: Firestore Streams

### Maps & Location
- **Map Display**: Flutter Map & Google Maps Flutter
- **Coordinates**: LatLong2
- **Geolocation**: Geolocator package
- **Distance Calculation**: Haversine formula (custom implementation)

### Platform Support
- Android
- iOS
- Web
- Windows
- macOS
- Linux

## Key Features Implementation

### Authentication Flow
1. Email/Password registration via Firebase Auth
2. Automatic email verification sent
3. Email verification check before app access
4. Session persistence across app restarts
5. Secure sign-out functionality

### Data Management
- **Real-time Sync**: Firestore streams for live updates
- **CRUD Operations**: Full create, read, update, delete support
- **Search**: Client-side filtering by name, address, description
- **Category Filter**: Dynamic filtering by service category
- **User Listings**: Filter listings by creator UID

### Map Features
- Display all listings as markers
- Show user's current location
- Calculate distances using Haversine formula
- Navigate to listing locations
- Interactive map controls

## Version

**1.0.0** - March 2026
