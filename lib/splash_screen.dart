import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/video_background.dart';
import 'home_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VideoBackground(
        videoAsset: 'assets/bgvideo.mp4',
        child: GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const HotelLogo(),
                const SizedBox(height: 40),
                Text(
                  'Tap here to start',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ).animate().fade(duration: 1.seconds, delay: 0.5.seconds),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HotelLogo extends StatelessWidget {
  const HotelLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Hotel',
          style: GoogleFonts.playfairDisplay(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 12,
          ),
        ).animate().fade(duration: 1.seconds).slide(),
        const SizedBox(height: 8),
        Text(
          'KIOSK',
          style: GoogleFonts.montserrat(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            letterSpacing: 16,
          ),
        ).animate().fade(duration: 1.seconds, delay: 0.3.seconds).slide(),
      ],
    );
  }
}