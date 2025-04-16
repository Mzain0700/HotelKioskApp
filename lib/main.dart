import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'Services/stripe_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Stripe
  Stripe.publishableKey = 'pk_test_51QxuV4CGkA9WhsUAkA5JNUyv72zZwSUlvJdcaGoXT9gTkGHaRc3pLpnRxlGKPFJAx6731YSvSmI6FB2VWor05XSW00w0OvQu56';
  await Stripe.instance.applySettings();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  runApp(const HotelKioskApp());
}

class HotelKioskApp extends StatelessWidget {
  const HotelKioskApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Kiosk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}

