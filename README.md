# Barber Shop Booking App

A Flutter application for booking barber shop appointments, built with clean architecture principles and modern Flutter practices.

## Features

- 📱 Phone number authentication
- 🔄 Role-based access (Business/Customer)
- 📅 Appointment scheduling and management
- 💈 Service management for businesses
- 🕒 Time slot management
- 🌐 RTL support for Arabic language
- 📊 Analytics tracking
- 🔔 Push notifications for appointments
- 📱 Offline support for core features
- ⭐ Review and rating system

## Getting Started

### Prerequisites

- Flutter SDK (3.7.2 or higher)
- Dart SDK (3.0.0 or higher)
- Firebase project setup
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/barber.git
   cd barber
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Firebase:

   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and place the configuration files:
     - Android: `google-services.json` in `android/app/`
     - iOS: `GoogleService-Info.plist` in `ios/Runner/`

4. Run the app:
   ```bash
   flutter run
   ```

## Architecture

The app follows Clean Architecture principles with the following layers:

```
lib/
├── core/           # Core functionality, shared across features
│   ├── constants/  # App-wide constants
│   ├── router/     # Navigation routing
│   └── services/   # Common services (storage, analytics, etc.)
│
├── features/       # Feature modules
│   ├── auth/       # Authentication feature
│   ├── business/   # Business-specific features
│   └── customer/   # Customer-specific features
│
└── main.dart       # Application entry point
```

### Authentication Flow

1. User enters phone number
2. Firebase sends OTP
3. User verifies OTP
4. If new user:
   - Select role (Business/Customer)
   - Complete profile
5. If existing user:
   - Redirect to appropriate home page based on role

### State Management

The app uses BLoC pattern with Cubit for state management:

- `AuthCubit`: Handles authentication state
- `BusinessCubit`: Manages business-specific state
- `CustomerCubit`: Manages customer-specific state

## Testing

### Running Tests

```bash
# Unit Tests
flutter test test/unit/

# Widget Tests
flutter test test/widget/

# Integration Tests
flutter test integration_test/
```

### Test Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
