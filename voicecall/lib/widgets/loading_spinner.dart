// widgets/loading_spinner.dart
import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 60.0, // Set a custom height
        width: 60.0, // Set a custom width
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.pink), // Customize color
          strokeWidth: 6.0, // Thicker spinner line
        ),
      ),
    );
  }
}
