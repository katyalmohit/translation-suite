import 'package:flutter/material.dart';

class CustomizedTextfield extends StatefulWidget {
  final TextEditingController myController;
  final String? hintText;
  final bool isPassword;
  final TextInputType keyboardType;

  const CustomizedTextfield({
    Key? key,
    required this.myController,
    this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  _CustomizedTextfieldState createState() => _CustomizedTextfieldState();
}

class _CustomizedTextfieldState extends State<CustomizedTextfield> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        controller: widget.myController,
        obscureText: widget.isPassword ? _obscureText : false,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xffE8ECF4), width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xffE8ECF4), width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          fillColor: const Color(0xffE8ECF4),
          filled: true,
          hintText: widget.hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
