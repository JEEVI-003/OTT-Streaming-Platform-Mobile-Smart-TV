import 'package:flutter/material.dart';


class MyTextFieldTV extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final Color focusColor;

  const MyTextFieldTV({
    Key? key,
    required this.controller,
    required this.icon,
    required this.hint,
    required this.inputType,
    required this.inputAction,
    required this.obscureText,
    this.suffixIcon,
    this.focusNode,
    this.nextFocusNode,
    this.focusColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36, // Reduced height
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: TextFormField(
          controller: controller,
          keyboardType: inputType,
          textInputAction: inputAction,
          obscureText: obscureText,
          focusNode: focusNode,
          style: TextStyle(color: Colors.white, fontSize: 12), // Smaller text
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10), // Reduced padding
            prefixIcon: Icon(icon, color: Colors.white, size: 12), // Smaller icon
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white54, fontSize: 10), // Smaller hint text
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), // Adjusted border radius
              borderSide: BorderSide(color: Colors.white, width: 0.5), // Thinner border
            ),
            suffixIcon: suffixIcon,
          ),
          onEditingComplete: () {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            } else {
              FocusScope.of(context).unfocus();
            }
          },
        ),
      ),
    );
  }
}
