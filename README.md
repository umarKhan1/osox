# OSOX Project Documentation

This document provides a comprehensive overview of the OSOX social application, covering its architecture, database schema, and core features.

## Project Overview

OSOX is a modern social media platform built with Flutter and Supabase. It offers a rich user experience featuring real-time communication, media sharing, and immersive story viewing. The application is designed with scalability and performance in mind, utilizing a robust feature-driven architecture.

## Getting Started

To run this project locally, follow these steps:

### 1. Prerequisites
- Flutter SDK (latest stable version)
- A Supabase project
- A Google Maps API key

### 2. Environment Setup
Create a `.env` file in the root directory by copying the `.env.example` file:
```bash
cp .env.example .env
```
Open the `.env` file and replace the placeholders with your actual Supabase URL and Anon Key:
```
SUPABASE_URL=your_actual_supabase_url
SUPABASE_ANON_KEY=your_actual_supabase_anon_key
```

### 3. API Keys Configuration

#### Android
Open `android/app/src/main/AndroidManifest.xml` and replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual Google Maps API key:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

#### iOS
Open `ios/Runner/AppDelegate.swift` and replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual Google Maps API key:
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

### 4. Run the App
Install dependencies and run the application:
```bash
flutter pub get
flutter run
```

## Core Technologies

- **Frontend**: Flutter
- **State Management**: BLoC / Cubit
- **Backend & Database**: Supabase (PostgreSQL)
- **Real-time**: Supabase Real-time (Postgres Changes)
- **Storage**: Supabase Storage for images and videos
- **Media Processing**: Video compression and image scaling
- **Dependency Injection**: GetIt (Service Locator)
- **Responsiveness**: ScreenUtil for multi-device support

## Application Architecture

The project follows a feature-driven Clean Architecture pattern. Each feature is self-contained with its own data, domain, and presentation layers.

### Folder Structure

- **lib/core**: Shared constants, themes, service locator, and utility services.
- **lib/features**: Module-based directory containing:
    - **activity**: User interactions and alerts.
    - **auth**: Authentication flows and state.
    - **chat**: Real-time messaging and media exchange.
    - **home**: Feed and stories management.
    - **posts**: Content creation and engagement.
    - **profile**: User data and connection management.
    - **search**: Discovery and search functionality.

## Supabase Schema Architecture

The backend infrastructure is built on Supabase, utilizing PostgreSQL for relational data and Row Level Security (RLS) for data protection.

### Database Tables

| Table Name | Description | Key Fields |
| --- | --- | --- |
| profiles | User profile information | id, full_name, avatar_url, email |
| stories | Short-lived media content | id, user_id, content_url, type, expires_at |
| story_views | Tracking story views | story_id, viewer_id, created_at |
| posts | Main feed content | id, user_id, caption, media_paths, location |
| post_likes | Post engagement | post_id, user_id, created_at |
| comments | Post discussion | id, post_id, user_id, content |
| messages | One-to-one communication | id, sender_id, receiver_id, content, image_url, reactions |

## Core Features

### Real-time Communication
The chat system utilizes Supabase's real-time capabilities to deliver messages instantly. It supports rich text, media attachments, message reactions, and reply chains.

### Dynamic Stories
Users can share ephemeral content that expires after 24 hours. The story viewer provides an immersive experience with auto-progression and viewer tracking.

### Content Engagement
The platform supports high-quality photo and video posts. Engagement features include real-time likes, threaded comments, and location tagging.

## Visual Reference

Below are visual representations of the application across various screens.

### Onboarding and Authentication
| Onboarding | Authentication |
|---|---|
| ![Onboarding](assets/images/images/Onboarding.png) | ![Authentication](assets/images/images/AuthScreen.png) |

### Main Experience
| Main Screen | Home Details |
|---|---|
| ![Main Screen](assets/images/images/main%20Screen.png) | ![Home Screen](assets/images/images/Home%20Screen.png) |

### Engagement and Content
| Stories | Messaging | Posts |
|---|---|---|
| ![Stories](assets/images/images/Stories%20Screen.png) | ![Messages](assets/images/images/Messages.png) | ![Post Screen](assets/images/images/Post%20Screen.png) |

### Discovery and Community
| Comments | Search | Profile |
|---|---|---|
| ![Comments](assets/images/images/Comments.png) | ![Search](assets/images/images/search%20screen.png) | ![Profile](assets/images/images/profile%20Screen.png) |

### Connections
![Following and Followers](assets/images/images/Following%20and%20Followers.png)

## Implementation Details

- **Video Processing**: Utilizes a dedicated video service for compression before upload, ensuring optimal load times.
- **Lazy Loading**: Implements range-based pagination for feeds and lists.
- **Optimistic Updates**: Provides immediate UI feedback for likes and deletions for a responsive feel.
- **Safety**: Uses Git and automated workflows for consistent builds and code quality checks.

---

## Open Source and Collaboration

OSOX is an open-source project dedicated to demonstrating modern Flutter and Supabase integration patterns. Contributions, suggestions, and feedback are welcome.

### Author

**Muhammad Omar**
LinkedIn: [muhammad-omar-0335](https://www.linkedin.com/in/muhammad-omar-0335/)
