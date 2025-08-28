# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is "디깅유학" (Digging Yuhak), a Flutter mobile app with Node.js backend for international education information, magazines, and community features. The app includes an interactive book gallery, user authentication system, and content management capabilities.

**⚠️ IMPORTANT: Production Deployment Information**
- **Production Server**: gunsiya.com (SSH port 26320, user: syrikx)
- **Backend Location**: `/home/syrikx/digging-yuhak-backend/` on production server
- **Database**: MongoDB running on production server (localhost:27017/diggingyuhak)
- **Live API URL**: `https://gunsiya.com/youhak/api`
- **Current Admin Account**: syrikx@gmail.com (role: admin)

**Do NOT assume local development environment - this project runs on gunsiya.com production server.**

## Common Development Commands

### Flutter Frontend
```bash
# Install dependencies
flutter pub get

# Run the app (development)
flutter run

# Run on specific device
flutter run -d <device-id>

# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .
```

### Backend (Production Server)
```bash
# Connect to production server
ssh -p 26320 syrikx@gunsiya.com

# Navigate to backend directory
cd digging-yuhak-backend/

# Install dependencies (if needed)
npm install

# Start production server
npm start
# or
node server.js
```

### Backend Environment Setup
The backend requires a `.env` file in the `digging-yuhak-backend/` directory on production server with:
- `MONGODB_URI`: MongoDB connection string (mongodb://localhost:27017/diggingyuhak)
- `JWT_SECRET`: Secret key for JWT token generation
- `NODE_ENV`: Environment (development/production)
- `PORT`: Server port (defaults to 5000)
- `BASE_PATH`: Optional base path for API routes (/youhak)

### Managing MongoDB on Production Server
```bash
# Connect to production server
ssh -p 26320 syrikx@gunsiya.com

# Access MongoDB (if mongo client is installed)
mongo diggingyuhak

# OR use Node.js script to query database
cd digging-yuhak-backend/
node -e "
require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./models/User');
// Add your MongoDB operations here
"
```

## Architecture Overview

### Frontend (Flutter)
- **State Management**: Provider pattern for authentication
- **API Integration**: Centralized ApiService class with token-based authentication
- **Screens**: Organized by feature (auth, books, community, magazine, admin, profile)
- **Navigation**: MaterialApp with custom drawer navigation
- **Theme**: Centralized AppTheme with light theme configuration

### Backend (Node.js + Express)
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT-based with bcrypt password hashing
- **API Structure**: RESTful routes organized by feature
- **Routes**: 
  - `/api/auth` - Authentication (login, register, profile)
  - `/api/users` - User management (admin functions)
  - `/api/magazines` - Magazine articles CRUD
  - `/api/community` - Community posts and replies
- **Middleware**: CORS enabled, JSON parsing, custom auth middleware

### Key Models
- **User**: Email, username, displayName, role (pending/member/admin), approval system
- **MagazineArticle**: Title, content, category, author, publication date
- **CommunityPost**: Title, content, type, author, replies

### Book Gallery System
- Books are stored as images in `assets/images/books/`
- Each book has full-size images and thumbnails
- Metadata stored in `metadata.json` files
- Interactive gallery with image viewer capabilities

### API Base URL
Production API: `https://gunsiya.com/youhak/api`

## Key Services and Providers

### ApiService (`lib/services/api_service.dart`)
- Handles all HTTP requests with automatic token management
- Centralized error handling with ApiException
- Token caching and refresh logic

### AuthProvider (`lib/providers/auth_provider.dart`)
- Manages authentication state using Provider pattern
- Handles login, logout, and user session management

### BookService (`lib/services/book_service.dart`)
- Manages local book data and metadata loading
- Handles book gallery functionality

## User Authentication Flow
1. Users register with approval required (role: 'pending')
2. Admin approves users, changing role to 'member' or 'admin'
3. JWT tokens have 7-day expiration
4. Token stored in SharedPreferences with caching

### Current Admin Access
- **Primary Admin**: syrikx@gmail.com (upgraded from pending to admin role)
- **Login Location**: Mobile app connects to https://gunsiya.com/youhak/api
- **Admin Panel Access**: Available in mobile app after login (bottom navigation "관리자" tab)

## Development Notes

### Flutter Specific
- App uses portrait orientation only
- Material Design with custom theming
- Image assets organized in structured folders
- Uses provider for state management across the app

### Backend Specific
- **Production Deployment**: Running on gunsiya.com server, NOT local environment
- MongoDB connection with error handling and graceful shutdown
- Comprehensive error middleware with development stack traces
- Health check endpoint at `/health` (https://gunsiya.com/youhak/health)
- User approval system for community access
- **Database Management**: All user data stored in production MongoDB (gunsiya.com)

### Admin Features
- User management (approve/reject pending users)
- Role assignment (member/admin)
- Magazine and community content management

## Build Configuration
- Android: Signing configured with `android/key.properties`
- iOS: Standard Xcode configuration
- Flutter version requirement: ">=3.0.0"
- Dart SDK requirement: ">=3.0.0 <4.0.0"