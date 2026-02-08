[![Latest release](https://img.shields.io/github/v/release/alfahrelrifananda/threshold?style=for-the-badge)](https://github.com/alfahrelrifananda/threshold/releases)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/github/license/alfahrelrifananda/threshold?style=for-the-badge)](LICENSE)

# Threshold

**Threshold** is a comprehensive screen time management app built with Flutter. Track app usage, set timers, and take control of your digital habits with ease.

[![Get it on GitHub](https://img.shields.io/badge/Get%20it%20on-GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/alfahrelrifananda/threshold/releases)

## Features

- **Real-time Usage Tracking** – Monitor every app with detailed session tracking
- **App Timers** – Set daily time limits (5-300 minutes) for any app
- **Home Screen Widgets** – Quick glance at screen time (1x1 and 2x2 sizes)
- **Beautiful Analytics** – Pie charts, line charts, and hourly breakdowns
- **Smart Filtering** – Ignore apps you don't want tracked
- **Privacy-First** – All data stays on your device, no internet required
- **Anti-Uninstall** – Device Admin protection for committed users

## Tech Stack

- **Language:** Dart & Kotlin
- **Framework:** Flutter 3.24+
- **UI:** Material Design 3
- **Charts:** fl_chart
- **Platform:** Android (API 24+)
- **Target SDK:** API 36

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable version)
- Android Studio / VS Code with Flutter extensions
- Android device or emulator (API 24+)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/alfahrelrifananda/threshold.git
   cd threshold
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Build APK

```bash
# Debug APK
flutter build apk

# Release APK
flutter build apk --release

# Split APKs by architecture
flutter build apk --split-per-abi
```

The APK will be available in `build/app/outputs/flutter-apk/`

## Required Permissions

Threshold requires the following permissions:

1. **Usage Access** – Track app usage statistics
2. **Accessibility Service** – Monitor app activity and enforce timers
3. **Display Over Other Apps** – Show timer notifications
4. **Device Administrator** – Prevent unauthorized app removal

All permissions are requested on first launch with clear explanations.

## Contributing

Contributions are what make the open-source community thrive! Feel free to:

- Fork the project
- Open issues for bugs or feature requests
- Submit pull requests with improvements
- Follow Flutter/Dart style guidelines

## License

This project is licensed under the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for more details.

## Acknowledgments

- Built with [Flutter](https://flutter.dev)
- Charts by [fl_chart](https://pub.dev/packages/fl_chart)
- Inspired by Digital Wellbeing
- Thanks to all contributors!

---

<p align="center">
  <a href="https://github.com/alfahrelrifananda/threshold">Star this repo</a> •
  <a href="https://github.com/alfahrelrifananda/threshold/issues">Report Bug</a> •
  <a href="https://github.com/alfahrelrifananda/threshold/issues">Request Feature</a>
</p>