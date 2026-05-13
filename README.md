# Hotel Kiosk App

A Flutter-based self-service hotel kiosk application for on-site **check-in**, **check-out**, **service requests**, **room key QR generation**, and **Stripe-based payment flow**.

## Purpose

Hotels need fast and low-friction guest operations without depending on front-desk staff for every step.  
This app provides a kiosk workflow where guests can:

- validate their booking
- confirm check-in details
- generate a room key QR
- request paid room services
- pay pending charges
- complete check-out or extend stay

## What this repository includes

- Multi-screen Flutter kiosk UI optimized for touch interactions
- Firebase integration for bookings, payments, and room key data
- Stripe card payment integration
- English and German localization support
- Inactivity detection with auto-reset to splash/home flow

## Detailed Documentation

For complete project details (problem statement, architecture, feature-by-feature behavior, data model, flows, setup notes, and known gaps), see:

- [DETAILED_DOCUMENTATION.md](./DETAILED_DOCUMENTATION.md)

## Tech Stack

- Flutter / Dart
- Firebase Core + Cloud Firestore
- Stripe (`flutter_stripe`)
- Video background (`video_player`)
- QR generation (`qr_flutter`)

## Project Structure (key app files)

- `lib/main.dart` – app bootstrap (Firebase + Stripe + immersive mode)
- `lib/splash_screen.dart` – entry splash experience
- `lib/home_page.dart` – language picker and check-in/check-out entry
- `lib/screens/` – check-in, check-out, payment, room key, services, success flows
- `lib/Services/payment_service.dart` – payment/charge write and history logic
- `lib/language/app_localizations.dart` – EN/DE strings
- `lib/utils/inactivity_timer.dart` – inactivity popup and auto-navigation

## Running Locally

1. Install Flutter SDK (matching project Dart/Flutter constraints).
2. Install dependencies:
   - `flutter pub get`
3. Run app:
   - `flutter run`

## Validation Notes

In this execution environment, Flutter CLI was not available (`flutter: command not found`), so `flutter analyze` and `flutter test` could not be executed here.
