import 'package:flutter/material.dart';

class CustomizedButton extends StatelessWidget {
  final String? buttonText;
  final Color? buttonColor;
  final Color? textColor;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onPressed;

  const CustomizedButton({
    Key? key,
    this.buttonText,
    this.buttonColor,
    this.textColor,
    this.onPressed,
    this.borderColor = Colors.transparent, // Default value if not provided
    this.borderRadius = 10.0, // Default rounded corners
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 70,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: buttonColor,
            border: Border.all(width: 1, color: borderColor!), // Customizable border color
            borderRadius: BorderRadius.circular(borderRadius), // Customizable border radius
          ),
          child: Center(
            child: Text(
              buttonText!,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
