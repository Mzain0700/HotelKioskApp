import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../splash_screen.dart';
import '../language/app_localizations.dart';
import 'language_provider.dart';

class InactivityTimer {
  static const Duration inactivityDuration = Duration(minutes: 1);
  static const Duration popupDuration = Duration(seconds: 10);

  Timer? _inactivityTimer;
  Timer? _popupTimer;
  int _remainingSeconds = 10;
  final BuildContext _context;
  bool _isPopupShowing = false;
  bool _isDisposed = false;

  InactivityTimer(this._context) {
    _resetInactivityTimer();
  }

  void _resetInactivityTimer() {
    if (_isDisposed) return;

    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(inactivityDuration, _showInactivityPopup);
  }

  void userActivityDetected() {
    if (_isDisposed || _isPopupShowing) return;

    _resetInactivityTimer();
  }

  void _showInactivityPopup() {
    // Check if already disposed or popup is showing
    if (_isDisposed || _isPopupShowing) return;

    // Check if context is still valid
    if (!_isContextValid()) {
      dispose();
      return;
    }

    _isPopupShowing = true;
    _remainingSeconds = 10;

    final localizations = AppLocalizations.of(LanguageProvider.currentLanguage);

    // Use a try-catch block to handle any potential errors
    try {
      showDialog(
        context: _context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              // Cancel any existing popup timer
              _popupTimer?.cancel();

              _popupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                // Check if the dialog is still in the tree before calling setState
                if (!_isDisposed && context.mounted) {
                  setState(() {
                    _remainingSeconds--;
                  });

                  if (_remainingSeconds <= 0) {
                    timer.cancel();
                    // Check if dialog is still showing before popping
                    if (Navigator.of(dialogContext).canPop()) {
                      Navigator.of(dialogContext).pop();
                    }
                    _navigateToSplashScreen();
                  }
                } else {
                  // If context is no longer valid, cancel the timer
                  timer.cancel();
                }
              });

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  localizations.get('still_there'),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localizations.get('inactive_notice'),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: _remainingSeconds / 10,
                            strokeWidth: 6,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF2D70)),
                          ),
                        ),
                        Text(
                          _remainingSeconds.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _popupTimer?.cancel();
                        if (Navigator.of(dialogContext).canPop()) {
                          Navigator.of(dialogContext).pop();
                        }
                        _isPopupShowing = false;
                        if (!_isDisposed) {
                          _resetInactivityTimer();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF2D70),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        localizations.get('yes_here'),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ).then((_) {
        // Dialog was closed
        if (_isPopupShowing && !_isDisposed) {
          _isPopupShowing = false;
          _resetInactivityTimer();
        }
      });
    } catch (e) {
      print('Error showing inactivity dialog: $e');
      _isPopupShowing = false;
      dispose();
    }
  }

  // Helper method to check if context is still valid
  bool _isContextValid() {
    try {
      return _context.mounted;
    } catch (e) {
      return false;
    }
  }

  void _navigateToSplashScreen() {
    // Check if context is still valid before navigating
    if (_isDisposed || !_isContextValid()) return;

    try {
      Navigator.of(_context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
            (route) => false,
      );
    } catch (e) {
      print('Error navigating to splash screen: $e');
    }
  }

  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    _inactivityTimer?.cancel();
    _popupTimer?.cancel();
    _inactivityTimer = null;
    _popupTimer = null;
  }
}