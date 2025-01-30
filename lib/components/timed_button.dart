import 'dart:async';
import 'package:flutter/material.dart';

class TimedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final int duration;

  const TimedButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.duration = 30,
  });

  @override
  TimedButtonState createState() => TimedButtonState();
}

class TimedButtonState extends State<TimedButton> {
  Timer? _timer;
  late int _seconds;
  late bool _isButtonActive;

  void startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _seconds = widget.duration;
      _isButtonActive = _seconds <= 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        setState(() {
          _timer!.cancel();
          _isButtonActive = true;
        });
      } else {
        setState(() {
          _seconds--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _isButtonActive
          ? () {
              widget.onPressed();
              startTimer(); // Restart the timer when button is pressed
            }
          : null, // Disable the button when _isButtonActive is false
      child: Text(
        _isButtonActive ? widget.label : 'Wait ${_seconds}s',
      ),
    );
  }
}
