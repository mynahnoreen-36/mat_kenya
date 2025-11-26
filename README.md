# MAT Kenya 🚌

**Kenya in Your Pocket** - A comprehensive Flutter application for managing and tracking matatu (public transport) routes and fares in Kenya.

> ⚠️ **Important:** This repository does not include sensitive configuration files (Firebase credentials, API keys). You must set these up locally before running the app. See the [Quick Start](#-quick-start) section below.

## 📖 Table of Contents

- [Quick Start](#-quick-start)
- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Firebase Setup](#firebase-setup)
- [Creating the Admin User](#creating-the-admin-user)
- [Running the App](#running-the-app)
- [Project Structure](#project-structure)
- [Key Technologies](#key-technologies)
- [Security & Configuration](#-security--configuration)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## 🚀 Quick Start

**Want to get the app running quickly?** Follow these essential steps:

1. **Clone and Install:**
   ```bash
   git clone https://github.com/mynahnoreen-36/mat_kenya.git
   cd mat_kenya
   flutter pub get
   ```

2. **Set Up Credentials** (Critical - app won't run without these):
   ```bash
   # Copy environment template
   cp .env.example .env

   # Edit .env and add your API keys (see SECURITY_SETUP.md)
   ```

3. **Get Firebase Config Files:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Download `google-services.json` → place in `android/app/`
   - Download `GoogleService-Info.plist` → place in `ios/Runner/`
   - See [SECURITY_SETUP.md](SECURITY_SETUP.md) for detailed steps

4. **Run the App:**
   ```bash
   flutter run
   ```

5. **Create Admin User:**
   - Navigate to Setup Admin page in the app
   - Follow instructions in [Creating the Admin User](#creating-the-admin-user)

**Need help?** See the [Installation](#installation) and [Firebase Setup](#firebase-setup) sections for detailed instructions.

## 🌟 Overview

MAT Kenya is a Flutter-based mobile application designed to help commuters and transport operators in Kenya manage matatu routes, track fares, and access real-time information about public transportation. The app provides both user and admin functionality for a complete transportation management system.

## ✨ Features

### User Features
- 📱 **User Authentication** - Sign up and log in with email/password
- 🗺️ **Interactive Maps** - View matatu routes on an interactive map
- 🎫 **Fare Information** - Check current fares for different routes
- 🚏 **Route Search** - Find routes between your origin and destination
- 👤 **User Profile** - Manage your account and preferences
- 🔔 **Push Notifications** - Get updates about routes and fares

### Admin Features
- 🔐 **Admin Panel** - Secure admin dashboard for managing the system
- ➕ **Route Management** - Create, update, and delete matatu routes
- 💰 **Fare Management** - Set and update fares for different routes
- ⏰ **Peak Hours** - Configure peak hour multipliers for dynamic pricing
- 📊 **User Management** - View and manage users
- 🛠️ **Admin Utilities** - Tools for system administration

## 📸 Screenshots

_Coming soon..._

## 🔧 Prerequisites

Before you begin, ensure you have the following installed on your system:

### Required Software

1. **Flutter SDK** (Latest stable version)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **Dart SDK** (Comes with Flutter)
   - Verify: `dart --version`

3. **Android Studio** or **Xcode** (for mobile development)
   - Android Studio for Android development
   - Xcode for iOS development (macOS only)

4. **Git**
   - Download from: https://git-scm.com/downloads
   - Verify: `git --version`

5. **Node.js** (v20 or later) - For Firebase Functions
   - Download from: https://nodejs.org/
   - Verify: `node --version`

6. **Firebase CLI** (Optional, for deploying cloud functions)
   - Install: `npm install -g firebase-tools`
   - Login: `firebase login`

### Optional Tools

- **Visual Studio Code** or **Android Studio** as your IDE
- **Flutter and Dart plugins** for your IDE
- **Chrome** (for web debugging)

## 📥 Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/mynahnoreen-36/mat_kenya.git
cd mat_kenya
```

### Step 2: Set Up Environment Variables and Credentials

**IMPORTANT:** This app requires sensitive configuration files that are not included in the repository for security reasons.

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Configure your credentials:**
   - Open `.env` and fill in your actual API keys and Firebase credentials
   - See [SECURITY_SETUP.md](SECURITY_SETUP.md) for detailed instructions

3. **Set up Firebase configuration files** (required before running the app):
   - Download `google-services.json` from Firebase Console
   - Place it at: `android/app/google-services.json`
   - Download `GoogleService-Info.plist` from Firebase Console
   - Place it at: `ios/Runner/GoogleService-Info.plist`

   Templates are provided at:
   - `android/app/google-services.json.example`
   - See [SECURITY_SETUP.md](SECURITY_SETUP.md) for step-by-step instructions

**Note:** Without these files, the app will not build or run. See the [Firebase Setup](#firebase-setup) section below for how to obtain these files.

### Step 3: Install Flutter Dependencies

```bash
flutter pub get
```

This will download all the necessary Flutter packages defined in `pubspec.yaml`.

### Step 4: Install Firebase Functions Dependencies

```bash
cd firebase/functions
npm install
cd ../..
```

### Step 5: Verify Flutter Installation

```bash
flutter doctor
```

Fix any issues reported by Flutter Doctor before proceeding.

### Step 6: Verify Firebase Configuration

Before running the app, verify your Firebase files are in place:

```bash
# Check Android config exists
ls -la android/app/google-services.json

# Check iOS config exists (if developing for iOS)
ls -la ios/Runner/GoogleService-Info.plist

# Verify .env file exists
ls -la .env
```

If any of these files are missing, refer to [SECURITY_SETUP.md](SECURITY_SETUP.md).

## 🔥 Firebase Setup

This app uses Firebase for authentication, database, and cloud functions. Follow these steps to set up Firebase:

### Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name (e.g., "MAT Kenya")
4. Follow the setup wizard

### Step 2: Enable Firebase Services

In your Firebase Console, enable the following services:

#### Authentication
1. Go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. (Optional) Enable other providers like Google, GitHub, Apple

#### Firestore Database
1. Go to **Firestore Database** → **Create database**
2. Choose **Start in production mode** (or test mode for development)
3. Select your region (preferably close to Kenya)

#### Cloud Functions
1. Upgrade to the **Blaze (pay-as-you-go)** plan if you want to use Cloud Functions
2. Note: There's a generous free tier

#### Push Notifications (Optional)
1. Go to **Cloud Messaging**
2. Follow setup instructions for Android/iOS

### Step 3: Configure Firebase in Your App

**CRITICAL:** You must add Firebase configuration files before the app will work.

#### For Android:

1. In [Firebase Console](https://console.firebase.google.com/), select your project
2. Click the **gear icon** → **Project settings**
3. Scroll down to **Your apps** section
4. If you haven't added an Android app yet:
   - Click **Add app** → Select **Android**
   - Package name: `com.mycompany.matKenya` (or whatever is in your `android/app/build.gradle`)
   - Register the app
5. Click **Download google-services.json**
6. Place the downloaded file at: `android/app/google-services.json`

#### For iOS:

1. In the same **Project settings** page
2. If you haven't added an iOS app yet:
   - Click **Add app** → Select **iOS**
   - Bundle ID: (find in `ios/Runner.xcodeproj/project.pbxproj`)
   - Register the app
3. Click **Download GoogleService-Info.plist**
4. Place the downloaded file at: `ios/Runner/GoogleService-Info.plist`

#### For Web:

The web configuration is already in `web/index.html`. You may need to update the Firebase config object with your project details.

#### Verification:

After adding the files, verify they exist:
```bash
ls -la android/app/google-services.json
ls -la ios/Runner/GoogleService-Info.plist
```

⚠️ **Security Note:** These files are in `.gitignore` and will NOT be committed to Git. Each developer must download their own copies.

For detailed instructions, see [SECURITY_SETUP.md](SECURITY_SETUP.md).

### Step 4: Update Firestore Security Rules

Deploy the security rules to protect your database:

```bash
firebase deploy --only firestore:rules
```

The rules are located in `firebase/firestore.rules`.

### Step 5: Deploy Cloud Functions (Optional)

```bash
cd firebase/functions
firebase deploy --only functions
```

## 👤 Creating the Admin User

Before you can access the admin features, you need to create a default admin user.

### Method 1: Using the Built-in Setup Page (Recommended)

1. **Run the app** (see [Running the App](#running-the-app))

2. **Navigate to the Setup Admin page:**
   - Add this temporary button to any page (e.g., login or signup page):
   ```dart
   TextButton(
     onPressed: () => context.pushNamed('SetupAdminPage'),
     child: const Text('Setup Admin'),
   )
   ```
   - Or navigate directly to URL: `/setupAdmin`

3. **Create the admin:**
   - Tap the "Create Admin User" button
   - Wait for confirmation

4. **Admin credentials:**
   - **Email:** mynahnoreen@gmail.com
   - **Password:** Kitiko.13936

5. **Log in with the admin account**

### Method 2: Using Code

You can also call the admin creation function directly:

```dart
import '/utils/create_default_admin.dart';

await CreateDefaultAdmin.createAdmin();
```

### Security Note

⚠️ **Important:** Change the default admin password after first login for security.

For detailed instructions, see [SETUP_ADMIN_QUICKSTART.md](SETUP_ADMIN_QUICKSTART.md).

## 🚀 Running the App

### For Android/iOS

#### Using Command Line

```bash
# Check connected devices
flutter devices

# Run on a connected device
flutter run

# Run in debug mode (default)
flutter run --debug

# Run in release mode (optimized)
flutter run --release

# Run on a specific device
flutter run -d <device-id>
```

#### Using IDE

**Visual Studio Code:**
1. Open the project
2. Press `F5` or click "Run" → "Start Debugging"

**Android Studio:**
1. Open the project
2. Select your device/emulator
3. Click the "Run" button (green triangle)

### For Web

```bash
# Run on Chrome
flutter run -d chrome

# Run on a specific port
flutter run -d chrome --web-port=8080
```

### For Desktop (Linux/Windows/macOS)

```bash
# Run on Linux
flutter run -d linux

# Run on Windows
flutter run -d windows

# Run on macOS
flutter run -d macos
```

### Hot Reload

While the app is running, you can make changes and see them instantly:
- Press `r` in the terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

## 📁 Project Structure

```
mat_kenya/
├── android/                  # Android-specific files
├── ios/                      # iOS-specific files
├── lib/                      # Main Flutter application code
│   ├── auth/                 # Authentication logic
│   │   └── firebase_auth/    # Firebase auth implementation
│   ├── backend/              # Backend services
│   │   ├── schema/           # Firestore data models
│   │   ├── cloud_functions/  # Cloud functions client
│   │   └── push_notifications/ # Push notification handlers
│   ├── flutter_flow/         # FlutterFlow generated code
│   │   ├── nav/              # Navigation and routing
│   │   └── flutter_flow_*.dart # UI components and utilities
│   ├── pages/                # App screens/pages
│   │   ├── welcome_page/     # Welcome/splash screen
│   │   ├── login_page/       # User login
│   │   ├── signup_page/      # User registration
│   │   ├── home_page/        # Main dashboard
│   │   ├── map_page/         # Interactive map view
│   │   ├── routes_page/      # Routes listing
│   │   ├── fares_page/       # Fares information
│   │   ├── admin_page/       # Admin dashboard
│   │   ├── profile_page/     # User profile
│   │   └── setup_admin_page/ # Admin user creation
│   ├── utils/                # Utility functions
│   │   └── create_default_admin.dart # Admin creation utility
│   ├── app_state.dart        # Global app state
│   ├── index.dart            # Page exports
│   └── main.dart             # App entry point
├── firebase/                 # Firebase configuration
│   ├── functions/            # Cloud Functions
│   │   ├── index.js          # Functions implementation
│   │   ├── package.json      # Node.js dependencies
│   │   └── create_default_admin.js # Admin creation script
│   ├── firestore.rules       # Firestore security rules
│   ├── firestore.indexes.json # Firestore indexes
│   └── firebase.json         # Firebase config
├── web/                      # Web-specific files
├── assets/                   # App assets (images, fonts, etc.)
├── test/                     # Unit and widget tests
├── pubspec.yaml              # Flutter dependencies
├── README.md                 # This file
├── SETUP_ADMIN_QUICKSTART.md # Quick admin setup guide
└── CREATE_DEFAULT_ADMIN.md   # Detailed admin creation guide
```

### Key Directories Explained

- **`lib/pages/`**: Contains all the UI screens of the app
- **`lib/backend/`**: Backend integration and data models
- **`lib/auth/`**: Authentication logic and user management
- **`firebase/functions/`**: Server-side Cloud Functions
- **`lib/flutter_flow/`**: Auto-generated FlutterFlow code

## 🛠️ Key Technologies

### Frontend
- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **FlutterFlow** - Visual development platform
- **Google Maps** - Interactive maps
- **Firebase Auth** - User authentication

### Backend
- **Firebase Firestore** - NoSQL cloud database
- **Firebase Cloud Functions** - Serverless backend
- **Firebase Cloud Messaging** - Push notifications
- **Node.js** - Cloud Functions runtime

### State Management
- **Provider** - State management solution

### Additional Libraries
- `cloud_firestore` - Firestore SDK
- `firebase_auth` - Authentication SDK
- `google_maps_flutter` - Maps integration
- `go_router` - Navigation and routing
- `flutter_animate` - Animations

## 🔒 Security & Configuration

### Important Security Files

This project uses several sensitive configuration files that are **NOT** included in the repository:

| File | Location | Purpose | How to Get |
|------|----------|---------|------------|
| `.env` | Project root | Environment variables & API keys | Copy from `.env.example` and fill in values |
| `google-services.json` | `android/app/` | Firebase Android config | Download from Firebase Console |
| `GoogleService-Info.plist` | `ios/Runner/` | Firebase iOS config | Download from Firebase Console |

### Security Best Practices

✅ **DO:**
- Keep your `.env` file up to date with required credentials
- Download fresh Firebase config files for each project
- Use different Firebase projects for development and production
- Change the default admin password after first login

❌ **DON'T:**
- Commit `.env`, `google-services.json`, or `GoogleService-Info.plist` to Git
- Share credentials via email, Slack, or other insecure channels
- Use production credentials in development
- Hardcode API keys in your source code

For complete security setup instructions, see [SECURITY_SETUP.md](SECURITY_SETUP.md).

## 🐛 Troubleshooting

### Common Issues

#### 1. Missing Configuration Files

**Problem:** Build fails with "google-services.json not found" or similar

**Solution:**
```bash
# Check if files exist
ls -la android/app/google-services.json
ls -la ios/Runner/GoogleService-Info.plist
ls -la .env

# If missing, follow the setup guide
# See SECURITY_SETUP.md for detailed instructions
```

Download the files from [Firebase Console](https://console.firebase.google.com/) and place them in the correct locations.

#### 2. Firebase Connection Issues

**Problem:** App can't connect to Firebase

**Solution:**
```bash
# Verify Firebase configuration files are present
flutter clean
flutter pub get

# Check Firebase project settings
# Ensure google-services.json (Android) or GoogleService-Info.plist (iOS) are present
# Verify package name/bundle ID matches your Firebase project
```

#### 3. Dependencies Issues

**Problem:** Package conflicts or version mismatches

**Solution:**
```bash
# Clean and reinstall dependencies
flutter clean
rm pubspec.lock
flutter pub get

# For Firebase Functions
cd firebase/functions
rm -rf node_modules package-lock.json
npm install
```

#### 4. Build Errors

**Problem:** Build fails with errors

**Solution:**
```bash
# Clean build cache
flutter clean

# Rebuild
flutter pub get
flutter run
```

#### 5. Environment Variables Not Loading

**Problem:** App can't find API keys or configuration

**Solution:**
```bash
# Verify .env file exists
ls -la .env

# If missing, copy from example
cp .env.example .env

# Edit .env and add your actual credentials
# See SECURITY_SETUP.md for what values to add
```

#### 6. Admin User Already Exists

**Problem:** Can't create admin user - already exists

**Solution:**
- The admin was already created successfully
- Just log in with the existing credentials:
  - Email: mynahnoreen@gmail.com
  - Password: Kitiko.13936

#### 7. Map Not Displaying

**Problem:** Google Maps shows blank or gray

**Solution:**
- Ensure you have a valid Google Maps API key in your `.env` file
- Check API key restrictions in Google Cloud Console
- Enable "Maps SDK for Android/iOS" in Google Cloud
- Verify the API key is properly configured in your app

#### 8. Flutter Doctor Issues

**Problem:** `flutter doctor` shows errors

**Solution:**
```bash
# Run flutter doctor and follow the suggested fixes
flutter doctor -v

# Common fixes:
# - Install missing Android SDK platforms
# - Accept Android licenses: flutter doctor --android-licenses
# - Install Xcode (macOS only)
```

### Getting Help

If you encounter issues not listed here:

1. Check the [Flutter documentation](https://flutter.dev/docs)
2. Check the [Firebase documentation](https://firebase.google.com/docs)
3. Search for similar issues on [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
4. Review the error logs in your terminal

## 📝 Development Notes

### Code Style

This project follows the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).

Run the formatter:
```bash
dart format .
```

### Testing

Run tests:
```bash
flutter test
```

### Building for Production

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle
```bash
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- Your Name - Initial work

## 🙏 Acknowledgments

- FlutterFlow for the visual development platform
- Firebase for backend services
- The Flutter community for excellent packages and support
- Kenyan matatu operators for inspiration

## 📞 Contact

For questions or support, please contact:
- Email: mynahnoreen@gmail.com

---

**Made with ❤️ in Kenya**

*Kenya in Your Pocket* 🇰🇪
