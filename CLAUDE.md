# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Daily Habits is a Flutter mobile application for tracking daily goals and habits with gamification features. The app supports offline mode with local storage and syncs with Firebase when online.

## Development Commands

### Essential Commands
```bash
# Get dependencies
flutter pub get

# Run the app (debug mode)
flutter run

# Build APK (Android)
flutter build apk

# Run all tests
flutter test

# Run a specific test file
flutter test test/services/reward_service_test.dart

# Run tests with coverage
flutter test --coverage

# Analyze code for issues
flutter analyze

# Clean build artifacts
flutter clean
```

### Firebase Commands
```bash
# List Firebase projects
firebase projects:list

# Select Firebase project (project ID: daily-habits-32eac)
firebase use daily-habits-32eac

# Deploy Firestore rules
firebase deploy --only firestore:rules
```

### Android-Specific Commands
```bash
# View signing report (run from android/ directory)
cd android && gradlew signingReport

# View logcat
adb logcat
```

## Architecture

### State Management
- **Provider pattern**: Primary state management using `ChangeNotifier`
  - `UserData` provider ([lib/models/user_data.dart](lib/models/user_data.dart)): Manages goals and completed tasks
  - `ThemeProvider` ([lib/providers/theme_provider.dart](lib/providers/theme_provider.dart)): Manages dark/light theme
- Providers are initialized in [lib/main.dart](lib/main.dart) using `MultiProvider`

### Data Layer Architecture

**Dual Storage System** (Online + Offline):
1. **Firebase (Cloud)**:
   - `FirebaseService` ([lib/services/firebase_service.dart](lib/services/firebase_service.dart)): Singleton service for all Firebase operations
   - Collections: `users/{uid}/goals`, `users/{uid}/completedGoals`, `users/{uid}/challenges`, `users/{uid}/rewards`, `users/{uid}/achievements`
   - Authentication via Firebase Auth with Google Sign-In support

2. **Hive (Local)**:
   - `LocalStorageService` ([lib/services/local_storage_service.dart](lib/services/local_storage_service.dart)): Local persistence using Hive boxes
   - Enables offline functionality
   - Stores goals and tasks locally

3. **Sync Layer**:
   - `SyncService` ([lib/services/sync_service.dart](lib/services/sync_service.dart)): Monitors connectivity and syncs local data with Firebase
   - Automatically syncs when connection is restored
   - Uses `connectivity_plus` to detect network changes

### Core Models

**Goal Model** ([lib/models/goals_model.dart](lib/models/goals_model.dart)):
- Three goal types: `kTypeCheckbox` (simple), `kTypeQuantity` (e.g., 8 glasses of water), `kTypeDuration` (e.g., 30 minutes)
- Periodicities: `kDaily`, `kWeekly`, `kMonthly`
- Supports specific weekdays for weekly goals
- `isVisible()`: Determines if goal should display on a given date
- `isCompletedForDate()`: Checks completion status against UserData tasks

**CompletedTask Model** ([lib/models/completed_goal.dart](lib/models/completed_goal.dart)):
- Tracks individual goal completions with timestamps
- Links to goals via `goalId`

**Challenge System**:
- Default challenges initialized on app startup ([lib/services/challenge_service.dart](lib/services/challenge_service.dart))
- Custom challenges created by users
- Progress tracking with rewards

### Key Services

All services follow the singleton pattern (`instance` getter):

- **Analytics & Monitoring**:
  - `AnalyticsService`: Firebase Analytics integration
  - `CrashlyticsService`: Error reporting and crash analytics

- **User Feedback**:
  - `SoundService`: Plays success sounds on goal completion (uses `audioplayers`)
  - `VibrationService`: Haptic feedback on goal completion
  - Both services check user preferences from SharedPreferences

- **Notifications**:
  - `NotificationService`: Local notifications for goal reminders
  - `SmartReminderService`: Intelligent reminder scheduling

- **Gamification**:
  - `ChallengeService`: Manages challenges and progress
  - `RewardService`: Handles reward system

- **Export/Import**:
  - `ExportService`: Export data to PDF/CSV formats

### Screen Flow

1. **Splash** → **Onboarding** (first-time users) → **Login/Home**
2. **Home** ([lib/screens/home.dart](lib/screens/home.dart)): Main screen with calendar and daily goals
   - Uses `TableCalendar` widget
   - Displays goals filtered by selected date
   - Settings affect display: show completed habits, show progress bars
3. **Side Menu Navigation**: Achievements, Challenges, Rewards, Statistics, Friends, Settings

### Settings System

Settings stored in SharedPreferences with keys like:
- `dark_mode`: Theme preference
- `sound_enabled`: Sound effects toggle
- `vibration_enabled`: Vibration toggle
- `show_completed`: Show completed habits
- `show_progress`: Show progress bars
- `week_start_day`: 0 (Sunday) or 1 (Monday)
- `date_format`: Date formatting preference

`DateFormatter` utility ([lib/utils/date_formatter.dart](lib/utils/date_formatter.dart)) provides consistent date formatting throughout the app.

### Localization

- Supports English and Spanish
- Generated localization files in [lib/l10n/](lib/l10n/)
- Uses Flutter's localization delegates
- Access via `AppLocalizations.of(context)`

## Important Implementation Notes

### Firebase Authentication
- Always check `FirebaseService.instance.isAuthenticated` before Firebase operations
- Services return empty data/streams for unauthenticated users to prevent permission errors
- Authentication state managed by Firebase Auth

### Offline Mode
- Goals and tasks automatically saved to Hive when created/updated
- App fully functional offline
- SyncService handles background sync when connectivity restored
- Handle both Firebase and Hive operations in parallel when online

### Goal Completion Logic
- For checkbox goals: Simple boolean completion
- For quantitative/duration goals: Track progress toward `targetValue`
- Progress calculation in `_getGoalProgress()` method sums all completion values for the day
- Completion dates normalized to midnight for consistent comparison

### Testing
- Uses `mocktail` for mocking
- `fake_cloud_firestore` for Firebase testing
- Test files mirror source structure: [test/models/](test/models/), [test/services/](test/services/), [test/widgets/](test/widgets/)

### Android Configuration
- Requires `VIBRATE` permission in AndroidManifest.xml
- Firebase configuration in [android/app/google-services.json](android/app/google-services.json)
- App signing configuration in [android/app/build.gradle](android/app/build.gradle)

## Common Patterns

### Adding a New Goal Type
1. Add type constant to `Goal` class (e.g., `kTypeNewType`)
2. Update `Goal.fromJson()` and `toJson()` to handle new fields
3. Modify goal creation UI in [lib/screens/create_goals.dart](lib/screens/create_goals.dart)
4. Update completion logic in home screen
5. Add progress calculation if needed

### Adding a New Service
1. Create service in [lib/services/](lib/services/)
2. Follow singleton pattern with `instance` getter
3. Add initialization in [lib/main.dart](lib/main.dart) `main()` if needed
4. Use SharedPreferences for persistent settings
5. Handle errors gracefully (service should work even if features unavailable)

### Adding a New Screen
1. Create screen in [lib/screens/](lib/screens/)
2. Add navigation route
3. Update side menu if needed ([lib/widgets/side_menu.dart](lib/widgets/side_menu.dart))
4. Register analytics screen view if tracking user flows

### Modifying Settings
1. Add UI toggle in [lib/screens/settings_screen.dart](lib/screens/settings_screen.dart)
2. Store preference in SharedPreferences
3. Load preference on app startup or screen initialization
4. Apply setting in relevant screens/widgets

## Assets

Sound file location (currently placeholder): [assets/sounds/success.mp3](assets/sounds/success.mp3)
Images in [assets/images/](assets/images/)

## Code Style

- Follows `flutter_lints` rules (see [analysis_options.yaml](analysis_options.yaml))
- Use `late` keyword for non-nullable fields initialized after construction
- Prefer `final` for immutable variables
- Use named parameters for constructors with multiple parameters
