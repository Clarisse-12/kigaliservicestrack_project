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
lib/
├── models/
├── services/
├── providers/
├── screens/
├── widgets/
├── firebase_options.dart
└── main.dart
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

## Version

**1.0.0** - March 2026
