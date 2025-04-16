import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/video_background.dart';
import 'language/app_localizations.dart';
import 'screens/check_out_screen.dart';
import 'screens/check_in_screen.dart';
import 'utils/language_provider.dart';
import 'utils/inactivity_detector.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentLanguage = 'en';
  late AppLocalizations _localizations;

  @override
  void initState() {
    super.initState();
    _localizations = AppLocalizations.of(_currentLanguage);
    LanguageProvider.setLanguage(_currentLanguage);
  }

  void _changeLanguage(String? newLanguage) {
    if (newLanguage != null) {
      setState(() {
        _currentLanguage = newLanguage.toLowerCase();
        _localizations = AppLocalizations.of(_currentLanguage);
        LanguageProvider.setLanguage(_currentLanguage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InactivityDetector(
      child: Scaffold(
        body: VideoBackground(
          videoAsset: 'assets/bgvideo.mp4',
          child: Stack(
            children: [
              // Language Selector
              Positioned(
                top: 32,
                right: 32,
                child: LanguageDropdown(
                  currentLanguage: _currentLanguage.toUpperCase(),
                  onChanged: _changeLanguage,
                ),
              ),
              // Main Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WelcomeTexts(localizations: _localizations),
                      const SizedBox(height: 64),
                      ActionButtons(
                        localizations: _localizations,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomeTexts extends StatelessWidget {
  final AppLocalizations localizations;

  const WelcomeTexts({
    Key? key,
    required this.localizations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          localizations.get('welcome'),
          style: GoogleFonts.playfairDisplay(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 4),
                blurRadius: 15,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          localizations.get('kiosk_title'),
          style: GoogleFonts.playfairDisplay(
            fontSize: 30,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 1.2,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 4),
                blurRadius: 15,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          localizations.get('select_option'),
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LanguageDropdown extends StatelessWidget {
  final String currentLanguage;
  final void Function(String?) onChanged;

  const LanguageDropdown({
    Key? key,
    required this.currentLanguage,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentLanguage,
          icon: const Icon(
            Icons.language,
            color: Colors.white,
            size: 24,
          ),
          dropdownColor: Colors.black.withOpacity(0.9),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          items: [
            DropdownMenuItem(
              value: 'EN',
              child: Row(
                children: [
                  const Text('🇬🇧 '),
                  const SizedBox(width: 8),
                  Text('English'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'DE',
              child: Row(
                children: [
                  const Text('🇩🇪 '),
                  const SizedBox(width: 8),
                  Text('Deutsch'),
                ],
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final AppLocalizations localizations;

  const ActionButtons({
    Key? key,
    required this.localizations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ActionButton(
          label: localizations.get('check_in'),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const CheckInScreen()),
            );
          },
        ),
        const SizedBox(height: 24),
        ActionButton(
          label: localizations.get('check_out'),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const CheckOutScreen()),
            );
          },
        ),
      ],
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const ActionButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: color != null
              ? [
            color!.withOpacity(0.8),
            color!,
          ]
              : [
            const Color(0xFFFF4D8D),
            const Color(0xFFFF2D70),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (color ?? const Color(0xFFFF2D70)).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(32),
          child: Center(
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

