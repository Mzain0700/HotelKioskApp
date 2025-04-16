import 'package:flutter/material.dart';
import 'inactivity_timer.dart';

class InactivityDetector extends StatefulWidget {
  final Widget child;
  final bool isEnabled;

  const InactivityDetector({
    Key? key,
    required this.child,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  _InactivityDetectorState createState() => _InactivityDetectorState();
}

class _InactivityDetectorState extends State<InactivityDetector> {
  InactivityTimer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _setupTimer();
  }

  @override
  void didUpdateWidget(InactivityDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle changes to isEnabled
    if (oldWidget.isEnabled != widget.isEnabled) {
      _inactivityTimer?.dispose();
      _setupTimer();
    }
  }

  void _setupTimer() {
    if (widget.isEnabled) {
      // Wait for the first frame to be rendered before creating the timer
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Only create a new timer if the widget is still mounted
        if (mounted) {
          _inactivityTimer = InactivityTimer(context);
        }
      });
    }
  }

  @override
  void dispose() {
    // Make sure to dispose the timer
    _inactivityTimer?.dispose();
    _inactivityTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return widget.child;
    }

    return Listener(
      behavior: HitTestBehavior.translucent, // Make sure all touches are detected
      onPointerDown: (_) => _inactivityTimer?.userActivityDetected(),
      onPointerMove: (_) => _inactivityTimer?.userActivityDetected(),
      onPointerUp: (_) => _inactivityTimer?.userActivityDetected(),
      child: widget.child,
    );
  }
}