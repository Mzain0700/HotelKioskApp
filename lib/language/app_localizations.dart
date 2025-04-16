class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Home Page
      'welcome': 'Welcome to',
      'kiosk_title': 'Self Check-in Kiosk',
      'select_option': 'Select an Option to Proceed',
      'check_in': 'Check-In',
      'check_out': 'Check-Out',
      'room_services': 'Room Services',
      'late_checkout': 'Late Check-out',
      'home_page': 'Home Page',

      'check_in_payment': 'Check-in Payment',
      'service_payment': 'Service Payment',
      'service_details': 'Service Details',
      'proceed_to_payment': 'Proceed to Payment',

      'remove_service': 'Remove Service',
      'remove_service_confirm': 'Are you sure you want to remove this service?',
      'remove': 'Remove',
      'service_removed_success': 'Service removed successfully',
      // For English:
      'checkout_details': 'Check-out Details',
      'name': 'Name',
      'check_out_successful': 'Check-out Successful',
      'thank_you_for_staying': 'Thank you for staying with us. We hope to see you again soon!',
      'return_to_home': 'Return to Home',
      'extend_stay': 'Extend Stay',
      'confirm_check_out': 'Confirm Check-out',
      'extend_stay_message': 'How many additional days would you like to stay?',
      'day': 'day',
      'days': 'days',
      'total_cost': 'Total Cost',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'recent_charges': 'Recent Charges',

      // Splash Screen
      'tap_to_start': 'Tap anywhere to start',
      'hotel': 'GRAND',
      'kiosk': 'HOTEL',

      // Check-in Screen
      'self_check_in': 'Self\nCheck-in',
      'surname': 'Surname',
      'enter_surname': 'Enter your surname',
      'booking_number': 'Booking Number',
      'enter_booking_number': 'Enter your booking number',
      'continue': 'Continue',
      'invalid_booking': 'Invalid booking details. Please try again.',
      'error_occurred': 'An error occurred. Please try again later.',

      // Check-out Screen
      'self_check_out': 'Self\nCheck-Out',

      // Booking Confirmation Screen
      'booking_confirmation': 'Booking Confirmation',
      'name': 'Name',
      'room_type': 'Room Type',
      'room_number': 'Room Number',
      'stay_duration': 'Stay Duration',
      'check_in_date': 'Check-in Date',
      'check_out_date': 'Check-out Date',
      'confirm_details': 'Please confirm your booking details',
      'confirm_generate_key': 'Generate Room Key',
      'modify_details': 'Modify Details',

      // Room Key Screen
      'your_room_key': 'Your Room Key',
      'room': 'Room',
      'scan_qr': 'Scan this QR code to unlock your room',
      'valid': 'Valid:',
      'done': 'Done',
      'request_services': 'Request Services',
      'error_generating_qr': 'Error generating QR code',
      'thank_you_choosing': 'Thank You for Choosing Us!',
      'returning_home': 'Returning to Home Page...',

      // Service Screen
      'room_services_title': 'Room Services',
      'current_total': 'Current Total:',
      'available_services': 'Available Services',
      'service_history': 'Service History',
      'thank_you_request': 'Thank You for Your Request!',

      // Service Items
      'room_cleaning': 'Room Cleaning',
      'room_cleaning_desc': 'Standard room cleaning service',
      'breakfast': 'Breakfast',
      'breakfast_desc': 'Continental breakfast delivered to your room',
      'laundry': 'Laundry',
      'laundry_desc': 'Laundry service for your clothes',
      'spa': 'Spa Treatment',
      'spa_desc': 'Relaxing spa treatment',
      'shuttle': 'Airport Shuttle',
      'shuttle_desc': 'Transportation to/from the airport',
      'towels': 'Extra Towels',
      'towels_desc': 'Additional fresh towels for your room',
      'add': 'Add',

      // Late Checkout Screen
      'extend_stay': 'Extend Your Stay',
      'current_checkout': 'Current Check-out',
      'select_nights': 'Select Additional Nights',
      'night': 'night',
      'nights': 'nights',
      'new_checkout': 'New Check-out Date',
      'room_rate': 'Room Rate',
      'additional_charge': 'Additional Charge',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'stay_extended': 'Stay Extended Successfully!',
      'checkout_updated': 'Your checkout date has been updated to',

      // Checkout Details Screen
      'checkout_details': 'Check-out Details',
      'nights_stayed': 'Nights Stayed',
      'room_charge': 'Room Charge',
      'service_charges': 'Service Charges',
      'total_payment': 'Total Payment',
      'recent_charges': 'Recent Charges',
      'payment': 'Payment',

      // Payment Screen
      'payment_title': 'Payment',
      'total_amount': 'Total Amount:',
      'card_information': 'Card Information',
      'enter_card_details': 'Enter card details',
      'cardholder_name': 'Cardholder Name',
      'enter_cardholder': 'Enter cardholder name',
      'pay': 'Pay',
      'payment_secure': 'Your payment is secure and encrypted',
      'secured_by': 'Secured by Stripe',

      // Payment Success Screen
      'payment_successful': 'Payment Successful!',
      'thank_you_payment': 'Thank you for your payment of',
      'checkout_processed': 'Your check-out has been processed successfully.',
      'returning_home_screen': 'Returning to home screen...',
      'return_home': 'Return to Home',

      // Inactivity Dialog
      'still_there': 'Are you still there?',
      'inactive_notice': 'We noticed you haven\'t been active for a while.',
      'yes_here': 'Yes, I\'m Here',
    },
    'de': {
      // Home Page
      'welcome': 'Willkommen im',
      'kiosk_title': 'Selbstbedienungs-Check-in',
      'select_option': 'Wählen Sie eine Option',
      'check_in': 'Einchecken',
      'check_out': 'Auschecken',
      'room_services': 'Zimmerservice',
      'late_checkout': 'Später Auschecken',
      'home_page': 'Startseite',

      'check_in_payment': 'Eincheck-Zahlung',
      'service_payment': 'Service-Zahlung',
      'service_details': 'Service-Details',
      'proceed_to_payment': 'Weiter zur Zahlung',

      'checkout_details': 'Auschecken Details',
      'name': 'Name',
      'check_out_successful': 'Auschecken erfolgreich',
      'thank_you_for_staying': 'Vielen Dank für Ihren Aufenthalt. Wir hoffen, Sie bald wieder zu sehen!',
      'return_to_home': 'Zurück zur Startseite',
      'extend_stay': 'Aufenthalt verlängern',
      'confirm_check_out': 'Auschecken bestätigen',
      'extend_stay_message': 'Wie viele zusätzliche Tage möchten Sie bleiben?',
      'day': 'Tag',
      'days': 'Tage',
      'total_cost': 'Gesamtkosten',
      'cancel': 'Abbrechen',
      'confirm': 'Bestätigen',
      'recent_charges': 'Aktuelle Gebühren',

      'remove_service': 'Service entfernen',
      'remove_service_confirm': 'Sind Sie sicher, dass Sie diesen Service entfernen möchten?',
      'remove': 'Entfernen',
      'service_removed_success': 'Service erfolgreich entfernt',

      // Splash Screen
      'tap_to_start': 'Tippen Sie, um zu beginnen',
      'hotel': 'GRAND',
      'kiosk': 'HOTEL',

      // Check-in Screen
      'self_check_in': 'Selbst\nEinchecken',
      'surname': 'Nachname',
      'enter_surname': 'Geben Sie Ihren Nachnamen ein',
      'booking_number': 'Buchungsnummer',
      'enter_booking_number': 'Geben Sie Ihre Buchungsnummer ein',
      'continue': 'Weiter',
      'invalid_booking': 'Ungültige Buchungsdetails. Bitte versuchen Sie es erneut.',
      'error_occurred': 'Ein Fehler ist aufgetreten. Bitte versuchen Sie es später erneut.',

      // Check-out Screen
      'self_check_out': 'Selbst\nAuschecken',

      // Booking Confirmation Screen
      'booking_confirmation': 'Buchungsbestätigung',
      'name': 'Name',
      'room_type': 'Zimmertyp',
      'room_number': 'Zimmernummer',
      'stay_duration': 'Aufenthaltsdauer',
      'check_in_date': 'Anreisedatum',
      'check_out_date': 'Abreisedatum',
      'confirm_details': 'Bitte bestätigen Sie Ihre Buchungsdetails',
      'confirm_generate_key': 'Zimmerschlüssel generieren',
      'modify_details': 'Details ändern',

      // Room Key Screen
      'your_room_key': 'Ihr Zimmerschlüssel',
      'room': 'Zimmer',
      'scan_qr': 'Scannen Sie diesen QR-Code, um Ihr Zimmer zu öffnen',
      'valid': 'Gültig:',
      'done': 'Fertig',
      'request_services': 'Services anfordern',
      'error_generating_qr': 'Fehler beim Generieren des QR-Codes',
      'thank_you_choosing': 'Vielen Dank, dass Sie uns gewählt haben!',
      'returning_home': 'Zurück zur Startseite...',

      // Service Screen
      'room_services_title': 'Zimmerservice',
      'current_total': 'Aktueller Gesamtbetrag:',
      'available_services': 'Verfügbare Dienste',
      'service_history': 'Servicehistorie',
      'thank_you_request': 'Vielen Dank für Ihre Anfrage!',

      // Service Items
      'room_cleaning': 'Zimmerreinigung',
      'room_cleaning_desc': 'Standard-Zimmerreinigungsservice',
      'breakfast': 'Frühstück',
      'breakfast_desc': 'Kontinentales Frühstück auf Ihr Zimmer geliefert',
      'laundry': 'Wäscheservice',
      'laundry_desc': 'Wäscheservice für Ihre Kleidung',
      'spa': 'Spa-Behandlung',
      'spa_desc': 'Entspannende Spa-Behandlung',
      'shuttle': 'Flughafentransfer',
      'shuttle_desc': 'Transport zum/vom Flughafen',
      'towels': 'Zusätzliche Handtücher',
      'towels_desc': 'Zusätzliche frische Handtücher für Ihr Zimmer',
      'add': 'Hinzufügen',

      // Late Checkout Screen
      'extend_stay': 'Verlängern Sie Ihren Aufenthalt',
      'current_checkout': 'Aktuelles Abreisedatum',
      'select_nights': 'Zusätzliche Nächte auswählen',
      'night': 'Nacht',
      'nights': 'Nächte',
      'new_checkout': 'Neues Abreisedatum',
      'room_rate': 'Zimmerpreis',
      'additional_charge': 'Zusätzliche Gebühr',
      'cancel': 'Abbrechen',
      'confirm': 'Bestätigen',
      'stay_extended': 'Aufenthalt erfolgreich verlängert!',
      'checkout_updated': 'Ihr Abreisedatum wurde aktualisiert auf',

      // Checkout Details Screen
      'checkout_details': 'Auschecken Details',
      'nights_stayed': 'Übernachtete Nächte',
      'room_charge': 'Zimmerkosten',
      'service_charges': 'Servicegebühren',
      'total_payment': 'Gesamtzahlung',
      'recent_charges': 'Aktuelle Gebühren',
      'payment': 'Zahlung',

      // Payment Screen
      'payment_title': 'Zahlung',
      'total_amount': 'Gesamtbetrag:',
      'card_information': 'Karteninformationen',
      'enter_card_details': 'Geben Sie Ihre Kartendetails ein',
      'cardholder_name': 'Name des Karteninhabers',
      'enter_cardholder': 'Geben Sie den Namen des Karteninhabers ein',
      'pay': 'Bezahlen',
      'payment_secure': 'Ihre Zahlung ist sicher und verschlüsselt',
      'secured_by': 'Gesichert durch Stripe',

      // Payment Success Screen
      'payment_successful': 'Zahlung erfolgreich!',
      'thank_you_payment': 'Vielen Dank für Ihre Zahlung von',
      'checkout_processed': 'Ihr Auschecken wurde erfolgreich verarbeitet.',
      'returning_home_screen': 'Zurück zum Startbildschirm...',
      'return_home': 'Zurück zur Startseite',

      // Inactivity Dialog
      'still_there': 'Sind Sie noch da?',
      'inactive_notice': 'Wir haben bemerkt, dass Sie eine Weile inaktiv waren.',
      'yes_here': 'Ja, ich bin hier',
    },
  };

  String get(String key) {
    return _localizedValues[languageCode]?[key] ?? _localizedValues['en']![key]!;
  }

  static AppLocalizations of(String languageCode) {
    return AppLocalizations(languageCode);
  }
}

