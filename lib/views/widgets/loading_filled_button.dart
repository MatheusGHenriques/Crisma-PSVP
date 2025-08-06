import '/data/notifiers.dart';
import 'package:flutter/material.dart';

class LoadingFilledButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String label;

  const LoadingFilledButton({super.key, required this.onPressed, required this.label});

  @override
  State<LoadingFilledButton> createState() => _LoadingFilledButtonState();
}

class _LoadingFilledButtonState extends State<LoadingFilledButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await widget.onPressed();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: _isLoading ? null : _handlePress,
      style: FilledButton.styleFrom(minimumSize: const Size(64, 44)),
      child:
          _isLoading
              ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: isDarkModeNotifier.value ? Colors.white : Colors.black,
                  strokeWidth: 2.5,
                ),
              )
              : Text(widget.label),
    );
  }
}
