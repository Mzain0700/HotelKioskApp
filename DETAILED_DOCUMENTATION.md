# Hotel Kiosk App – Detailed Documentation

## 1) Project Summary

The Hotel Kiosk App is a Flutter kiosk solution for hotel guests to self-serve core front-desk operations:

- Check-in validation and confirmation
- Room key QR generation
- In-stay paid service requests
- Payment collection
- Check-out and optional stay extension

The app is designed for touch-first usage, multilingual support (English/German), and unattended kiosk behavior (inactivity timeout flow).

---

## 2) Problem Being Solved

Hotels often face these operational issues:

1. Front-desk congestion during peak check-in/check-out times
2. Delays in processing guest requests and incremental charges
3. Higher staffing pressure for repetitive transactions
4. Inconsistent guest experience across staff shifts

This app addresses these by enabling a guided self-service kiosk flow backed by centralized Firebase data and integrated payment handling.

---

## 3) Core Purpose

The system’s purpose is to provide an end-to-end guest transaction journey in one kiosk interface:

- identify booking
- confirm stay details
- issue digital room access payload (QR)
- capture additional service charges
- collect payment securely through Stripe SDK
- finalize booking state in Firestore

---

## 4) High-Level Feature List

1. **Splash + Start screen** with branded visuals and tap-to-start interaction
2. **Language switcher** (EN/DE) from the home screen
3. **Self Check-in**
   - validates surname + booking number against Firestore
   - displays booking confirmation
   - updates booking status to `confirmed`
4. **Room key QR generation**
   - creates unique key payload
   - stores key record in `room_keys`
5. **Room services**
   - fixed catalog (cleaning, breakfast, laundry, spa, shuttle, towels)
   - adds/removes service charges
   - maintains payment history entries
6. **Payment details + payment screen**
   - computes room and service totals
   - card entry using Stripe card field
   - creates and confirms payment intent
   - records payment and updates booking status
7. **Self Check-out**
   - validates booking
   - shows charges and recent history
   - allows stay extension with extra charges
   - supports final check-out confirmation
8. **Inactivity protection**
   - inactivity popup after timeout
   - auto-return to splash if no response

---

## 5) Main User Flows

## 5.1 Check-In Flow

1. Splash screen → tap to continue
2. Home → choose **Check-In**
3. Enter surname + booking number
4. App queries `bookings` collection
5. If valid:
   - booking confirmation screen shown
   - user confirms details
   - booking status set to `confirmed`
6. Room key screen:
   - generates QR payload
   - writes key data to `room_keys/{bookingNumber}`
7. User can either:
   - proceed directly toward payment detail screen, or
   - open service request screen first

## 5.2 Service Request Flow

1. Service screen loads current payment amount and history
2. User adds service items (fixed price catalog)
3. Charges are appended in `payments/{bookingNumber}/history` with type `service`
4. Running total updates in `payments/{bookingNumber}`
5. User can remove a service item (history record removed; amount reduced)
6. User proceeds to payment detail screen

## 5.3 Payment Flow

1. Payment detail screen calculates total from room + services
2. Payment screen collects card data and cardholder name
3. App creates Stripe payment intent via HTTP
4. App confirms payment with Stripe SDK
5. Payment record is written to Firestore (`type: payment`)
6. Booking status is updated to `completed`
7. Success screen shows confirmation and auto-returns home

## 5.4 Check-Out Flow

1. Home → choose **Check-Out**
2. Enter surname + booking number
3. Booking is validated from Firestore
4. Checkout details view shows booking + charges
5. User can:
   - confirm check-out (booking set to completed), or
   - extend stay (additional day count and charge)
6. For stay extension, booking dates are updated and additional charge is added

---

## 6) Data Usage (Firestore-Oriented)

## 6.1 `bookings`

Referenced fields include:

- `surname`
- `bookingNumber`
- `guestName`
- `roomType`
- `roomNumber`
- `nights`
- `checkInDate`
- `checkOutDate`
- `roomRate`
- `status`
- extension and timestamp fields (`isExtended`, `extendedDays`, etc.)

## 6.2 `payments/{bookingNumber}`

Root document fields:

- `amount` (current payable amount)
- `lastUpdated`
- `lastPaymentAmount`
- `lastPaymentDate`

Subcollection `history` entries:

- `amount`
- `description`
- `timestamp`
- `type` (`service`, `room`, `late_checkout`, `payment`)

## 6.3 `room_keys/{bookingNumber}`

Stored key info:

- `roomNumber`
- `keyData` (QR payload)
- `checkInDate`
- `checkOutDate`
- `createdAt`

---

## 7) Localization

- Localization is handled by a custom map-based class in `lib/language/app_localizations.dart`.
- Supported language codes:
  - `en` (English)
  - `de` (German)
- Selected language is stored via a simple in-memory `LanguageProvider`.

---

## 8) Inactivity / Kiosk Safety Behavior

- Inactivity timer triggers after **1 minute**.
- A confirmation dialog appears with a **10-second** countdown.
- If user does not respond, app navigates back to splash flow.
- Activity resets timer through pointer interaction listeners.

---

## 9) Technical Architecture Notes

- UI: Flutter widget screens in `lib/screens/`
- Shared UX component: reusable video background layer
- Payment domain logic: `PaymentService`
- State handling: local widget state (setState), no external state framework
- Navigation: imperative Flutter navigation stack (push / pushReplacement / pushAndRemoveUntil)

---

## 10) Known Gaps / Risks (Current Implementation)

1. **Sensitive key handling risk**  
   Stripe keys are embedded in client-side code. In production, secret key operations should be moved to a backend.

2. **Test suite mismatch**  
   The default widget test references a `MyApp` widget pattern that does not match the current `main.dart` app class, so tests need alignment.

3. **Limited validation hardening**  
   Current guest input validation is minimal and could be expanded for stricter kiosk reliability.

4. **Service catalog is static in UI code**  
   Service item configuration is not yet dynamic from backend settings.

---

## 11) Repository Paths (Important)

- App bootstrap: `lib/main.dart`
- Home entry: `lib/home_page.dart`
- Splash: `lib/splash_screen.dart`
- Screens: `lib/screens/`
- Payment logic: `lib/Services/payment_service.dart`
- Localization: `lib/language/app_localizations.dart`
- Inactivity: `lib/utils/inactivity_timer.dart`, `lib/utils/inactivity_detector.dart`
- Main README: `README.md`

---

## 12) Setup and Run

1. Ensure Flutter SDK is installed.
2. Run:
   - `flutter pub get`
   - `flutter run`
3. Configure Firebase project files and Stripe environment approach before production deployment.

