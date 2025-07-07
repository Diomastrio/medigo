# MediGO Project

## Overview
MediGO is a Flutter application designed to help users manage their medication schedules effectively. The app provides functionalities for user authentication, medication tracking, and reminders.

## Features
- User registration and login
- Dashboard for medication management
- Home screen with quick access to features
- Medication details and reminders

## Project Structure
```
medigo
├── lib
│   ├── main.dart                # Entry point of the application
│   ├── screens
│   │   ├── dashboard_screen.dart # Main screen after authentication
│   │   ├── home_screen.dart      # Home screen layout
│   │   └── auth_screen.dart      # User authentication screen
│   ├── widgets
│   │   ├── medication_card.dart   # Displays medication information
│   │   ├── dose_reminder_card.dart # Reminder for medication doses
│   │   └── feature_grid.dart      # Grid layout for app features
│   └── models
│       └── medication.dart        # Medication model definition
├── assets
│   ├── images                    # Image assets
│   └── fonts                     # Custom font files
├── pubspec.yaml                  # Flutter project configuration
└── README.md                     # Project documentation
```

## Setup Instructions
1. Clone the repository:
   ```
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```
   cd medigo
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run the application:
   ```
   flutter run
   ```

## Usage
- Launch the app and register a new account or log in with existing credentials.
- Access the dashboard to view and manage medications.
- Use the home screen for quick navigation to various features.

## Contributing
Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.