# EmpManager — Flutter Employee Management System

A full-featured employee management app built with Flutter, Firebase Auth, Cloud Firestore, FCM, Provider, and Material 3.

---

## Project Structure

```
lib/
├── main.dart                        # App entry point, routes, providers
├── firebase_options.dart            # Firebase config (YOU MUST FILL THIS IN)
├── models/
│   └── employee.dart                # Employee data model
├── services/
│   ├── auth_service.dart            # Firebase Auth wrapper
│   ├── employee_service.dart        # Firestore CRUD operations
│   └── notification_service.dart    # FCM + local notifications
├── providers/
│   ├── auth_provider.dart           # Auth state management
│   └── employee_provider.dart       # Employee state management
├── screens/
│   ├── splash_screen.dart           # Animated splash + auth check
│   ├── login_screen.dart            # Email/password login
│   ├── register_screen.dart         # New account registration
│   ├── forgot_password_screen.dart  # Password reset + mock OTP screen
│   ├── dashboard_screen.dart        # Stats, department breakdown, quick actions
│   ├── employee_list_screen.dart    # Searchable list with swipe-to-delete
│   ├── employee_detail_screen.dart  # Full employee profile
│   └── add_edit_employee_screen.dart # Add / edit form with full validation
├── widgets/
│   └── common_widgets.dart          # LoadingOverlay, StatCard, EmptyState, etc.
└── utils/
    └── app_theme.dart               # Theme, constants, validators, formatters
```

---

## Prerequisites

- Flutter SDK ≥ 3.0.0 (run `flutter --version` to check)
- A Firebase project (free Spark plan is fine)
- Node.js (for FlutterFire CLI)

---

## Step 1 — Create Your Firebase Project

1. Go to https://console.firebase.google.com
2. Click **Add project** → give it a name (e.g. `emp-manager`)
3. Disable Google Analytics if not needed → **Create project**

---

## Step 2 — Enable Firebase Authentication

1. In the Firebase console, click **Authentication** → **Get started**
2. Under **Sign-in method**, enable **Email/Password**
3. Click **Save**

---

## Step 3 — Enable Cloud Firestore

1. Click **Firestore Database** → **Create database**
2. Choose **Start in production mode** (rules are set below)
3. Pick a region close to your users → **Enable**

### Apply Firestore Rules

In the Firebase console → **Firestore Database** → **Rules** tab, paste the contents of `firestore.rules` and click **Publish**.

---

## Step 4 — Enable Firebase Cloud Messaging

FCM is enabled by default for every Firebase project. No extra setup needed in the console.

For iOS, you also need to:
1. Upload your APNs Authentication Key in Firebase console → **Project Settings** → **Cloud Messaging**
2. Add `FLUTTER_APPLICATION_PATH` and background entitlements to your Xcode project (done automatically by FlutterFire CLI)

---

## Step 5 — Add Your Apps to Firebase

### Android
1. Firebase console → **Project Settings** → **Add app** → Android icon
2. Enter your package name (default: `com.example.employee_management`) — match it in `android/app/build.gradle`
3. Download `google-services.json` → place it in `android/app/`
4. Follow the console instructions to add the Google services plugin

### iOS
1. Firebase console → **Add app** → iOS icon
2. Enter your Bundle ID (e.g. `com.example.employeeManagement`)
3. Download `GoogleService-Info.plist` → drag it into your Xcode project root
4. Follow the console instructions

---

## Step 6 — Configure firebase_options.dart

The easiest way is the FlutterFire CLI:

```bash
# Install FlutterFire CLI (once)
dart pub global activate flutterfire_cli

# In the project root, run:
flutterfire configure
```

This auto-generates `lib/firebase_options.dart` with the correct values for all platforms.

**OR** manually open `lib/firebase_options.dart` and replace every `YOUR_*` placeholder with the real values from Firebase console → **Project Settings** → **Your apps**.

---

## Step 7 — Android Setup

In `android/app/build.gradle`, set:

```gradle
android {
    defaultConfig {
        applicationId "com.example.employee_management"
        minSdk 23          // required for Firebase Auth
        targetSdk 34
    }
}
```

In `android/build.gradle` (project-level), add to `dependencies`:
```gradle
classpath 'com.google.gms:google-services:4.4.0'
```

In `android/app/build.gradle` (app-level), add at the bottom:
```gradle
apply plugin: 'com.google.gms.google-services'
```

---

## Step 8 — iOS Setup

In `ios/Runner/Info.plist`, add:
```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

---

## Step 9 — Install Dependencies & Run

```bash
# In the project root:
flutter pub get
flutter run
```

---

## Features Summary

| Feature | Detail |
|---|---|
| Authentication | Email/password login, register, forgot password, mock OTP demo |
| Splash Screen | Animated logo, auto-routes based on auth state |
| Dashboard | Total employees, departments, avg salary, payroll, department chart |
| Employee List | Real-time stream, search, swipe to edit/delete |
| Add Employee | Full form with all 9 fields, validation, date picker, dropdowns |
| Edit Employee | Pre-populated form, unique ID/email validation excluding self |
| Employee Detail | Expandable SliverAppBar, full profile view |
| Notifications | Local push notification on add, update, delete |
| State Management | Provider with real-time Firestore stream |

---

## Validation Rules

- All fields are mandatory
- Email must be a valid email address
- Phone must be exactly 10 digits
- Salary must be a positive number
- Employee ID and email must be unique across all employees

---

## Demo Credentials

After running the app, register a new account on the Register screen. There are no pre-seeded accounts since Firebase Auth requires real credentials.

Mock OTP demo code: **123456**

---

## Firestore Collection Structure

Collection: `employees`

```
{
  "name": "Jane Smith",
  "employeeId": "EMP042",
  "email": "jane@company.com",
  "phone": "9876543210",
  "department": "Engineering",
  "designation": "Senior Developer",
  "salary": 95000,
  "joiningDate": Timestamp,
  "address": "42 Maple Ave, San Francisco, CA",
  "createdAt": Timestamp
}
```

---

## Troubleshooting

**`google-services.json not found`** — Ensure the file is in `android/app/` (not the project root).

**`FirebaseException: [core/no-app]`** — You haven't replaced the placeholder values in `firebase_options.dart` yet.

**Notifications not appearing on iOS** — APNs key not uploaded to Firebase, or background modes missing from `Info.plist`.

**`MissingPluginException` for flutter_local_notifications** — Run `flutter clean && flutter pub get` then rebuild.
