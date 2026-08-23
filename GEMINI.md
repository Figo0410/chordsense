# ChordSense Workspace Guidance

Welcome to the **ChordSense** project. This file provides architectural context, project structure details, build and run instructions, and key development conventions. Use this document as your primary reference for future interactions.

---

## 1. Project Overview

ChordSense is a full-stack, interactive guitar/instrument learning, tuning, and progress-tracking application. 

### Architecture
- **Frontend (Flutter)**: A cross-platform UI targeting mobile (Android, iOS), desktop (Windows, macOS, Linux), and web. It leverages real-time digital signal processing (DSP) to capture mic inputs, perform pitch detection, and guide users through chord lessons and reference tuning.
- **Backend (Node.js/Express)**: A lightweight CommonJS REST API that connects to MongoDB via Mongoose. It manages authentication, registration with email verification OTP, songs, lesson paths, and device-to-cloud synchronization of user progress.

---

## 2. Directory & Module Guide

### Frontend (Flutter Client)
The core client application is located in the root and under `/lib`.

*   **`lib/main.dart`**: Entrypoint of the Flutter application. Sets up global Material 3 dark-mode styling, defines initial routes (`/`, `/admin`, `/register`, `/forgot-password`), and kicks off network auto-detection and background sync asynchronously during initialization.
*   **`lib/services/api_service.dart`**: Central network coordinator. Features a robust **Dynamic IP Scanner** that automatically pings a list of candidate host IPs (for local host, emulators, and physical device hotspots/Wi-Fi) on port `5000` to find and cache the reachable API host across different development environments.
*   **`lib/*_screen.dart`**: Modular UI screens including:
    *   **User/Admin dashboards**: `user_dashboard.dart`, `admin_screen.dart`.
    *   **Auth flows**: `login_screen.dart`, `register_screen.dart`, `forgot_password_screen.dart`, `new_password_screen.dart`.
    *   **DSP / Core features**: `tuner_screen.dart` (guitar tuner using pitch estimation), `guided_play_screen.dart` (visual chord playing), `practice_session_screen.dart`.
    *   **Progress & Gamification**: `learning_path_screen.dart`, `progress_screen.dart`, `achievements_screen.dart` (badges), `ranking_screen.dart` (points leaderboards), `song_library_screen.dart`, and `request_song_screen.dart`.
*   **`packages/flutter_fft`**: A local package dependency providing specialized Fast Fourier Transform algorithms for audio frequency analysis and pitch estimation.
*   **`assets/audio/`**: Local audio resource directory (e.g., `G.mp3` for string reference tuning).

### Backend (Express Server)
The backend REST API is governed by `backend/server.js` and standard Node.js directories located within the `backend/` folder.

*   **`backend/server.js`**: Server configuration, middleware loading (CORS, Express JSON body parsing), and API route declarations. Restricts DNS resolution to IPv4 first (`dns.setDefaultResultOrder('ipv4first')`) to prevent connection lag on certain development setups.
*   **`backend/config/db.js`**: Database connector that connects to MongoDB using Mongoose and the environment variable `MONGO_URI`.
*   **`backend/models/`**: MongoDB schemas.
    *   `User.js`: Schema tracking user credentials, roles, total points, accuracy, streak, and complete progress metrics. It mirrors the exact data structure used by the Flutter app for local-to-cloud synchronization (e.g., `completedChords`, `learningChords`, `practiceSessions`, `completedLevels`, `badgeHistory`).
    *   `Song.js`: Schema representing playable songs.
    *   `LearningPath.js`: Schema for lesson structures, target chords, and point weights.
*   **`backend/routes/`**: API endpoint routers.
    *   `authRoutes.js`: Multi-step registration (sending OTP, verification, registration), password reset, and login. Includes hybrid offline fallbacks.
    *   `songRoutes.js`: Metadata, request logs, and management endpoints.
    *   `learningPathRoutes.js`: Level configs, lesson completion records.
    *   `syncRoutes.js`: Synchronization endpoints allowing clients to push and merge local session data with MongoDB.
*   **`backend/utils/badgeHelper.js`**: Helper function verifying user criteria (e.g., completed levels, tuner completion, precision milestones) to award badges and update point balances.

---

## 3. Build, Run, and Development Commands

### Backend (Node.js)
Navigate to the `backend/` directory and ensure you have a `.env` file containing:
```env
MONGO_URI=mongodb://localhost:27017/chordsense
PORT=5000
NODE_ENV=development
```

*   **Install Dependencies**:
    ```bash
    cd backend
    npm install
    ```
*   **Run in Development (with Nodemon hot-reload)**:
    ```bash
    cd backend
    npm run dev
    ```
*   **Run in Production**:
    ```bash
    cd backend
    npm start
    ```

### Frontend (Flutter Client)

*   **Install Dependencies & Get Packages**:
    ```bash
    flutter pub get
    ```
*   **Clean Build Caches**:
    ```bash
    flutter clean
    ```
*   **Run / Launch Application**:
    ```bash
    flutter run
    ```
    To specify a target platform or device:
    ```bash
    flutter run -d chrome
    # or
    flutter run -d windows
    ```
*   **Code Analysis & Linting**:
    ```bash
    flutter analyze
    ```
*   **Code Formatting**:
    ```bash
    dart format .
    ```
*   **Execute Widget/Unit Tests**:
    ```bash
    flutter test
    ```

---

## 4. Key Development Conventions

1.  **Network Resolution**:
    *   Do not hardcode IP addresses inside your Flutter network calls. Always use `ApiService` wrappers (`ApiService.post()`, `ApiService.login()`, etc.) to execute requests. This ensures that the application resolves and targets the active server IP automatically across emulators and actual devices.
2.  **Hybrid Verification Fallbacks**:
    *   If Node.js fails to dispatch registration OTP emails via Gmail SMTP, it falls back automatically to a local CLI developer console logger (Offline Demo Mode). When testing or creating users locally, check the backend console output for the 6-digit registration code.
3.  **Synchronization Alignment**:
    *   When adding or updating local tracking parameters on the Flutter client (e.g., new types of practice goals or chord attempts), ensure they are reflected in the `User` mongoose schema in `/models/User.js` and handled correctly within the `/api/sync` push routes.
4.  **Audio Permissions & Mic**:
    *   Tuning and playing modes require microphone permissions. Ensure the standard `permission_handler` checks are invoked prior to initialising listening services inside client controllers.
5.  **Code Quality**:
    *   Adhere to strict Dart rules outlined in `analysis_options.yaml` (`package:flutter_lints/flutter.yaml`). Avoid bypassing the type system with raw dynamic types unless absolutely necessary.

