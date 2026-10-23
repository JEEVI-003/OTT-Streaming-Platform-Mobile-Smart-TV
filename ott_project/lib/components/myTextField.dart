import 'package:flutter/material.dart';
import 'package:ott_project/components/pallete.dart';

class MyTextField extends StatefulWidget {

  final IconData icon;
  IconButton? suffixIcon;
  final String hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final bool obscureText;
  final TextEditingController? confirmPasswordController;
  final Widget? suffix;
   MyTextField(
      {super.key,
      required this.icon,
      this.suffixIcon,
      required this.hint,
      this.controller,
      required this.inputType,
      required this.inputAction,
      required this.obscureText,
      this.validator,
      this.suffix,
      this.confirmPasswordController});

  

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  String? errorText;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            height: size.height * 0.08,
            width: size.width * 0.9,
            decoration: BoxDecoration(
              color: Color.fromRGBO(28, 38, 74, 0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: errorText != null ? Colors.red : Colors.white),
            ),
            child: Stack(
              children: [
                Center(
                  //constraints: BoxConstraints(minHeight: size.height * 0.07),
                  child: TextFormField(
                    controller: widget.controller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 10, top: 0),
                        child: Icon(
                          widget.icon,
                          size: 20,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      suffixIcon: widget.suffixIcon,
                      suffix: widget.suffix,
                      hintText: widget.hint,
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Colors.white54),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      isDense: true,
                    ),
                    obscureText: widget.obscureText,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    keyboardType: widget.inputType,
                  
                    textInputAction: widget.inputAction,
                    validator: (value) {
                      setState(() {
                        errorText = _getErrorText(value);
                      });
                      return errorText;
                    },
                    onChanged: (value) {
                      if (errorText != null) {
                        setState(() {
                          errorText = _getErrorText(value);
                        });
                      }
                    },
                 
                  ),
                ),
                if (errorText != null)
                  Positioned(
                    right: 10,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Tooltip(
                        message: errorText!,
                        preferBelow: false,
                        child: Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String? _getErrorText(String? value) {
    if (widget.validator != null) {
      final validatorResult = widget.validator!(value);
      if (validatorResult != null) {
        return validatorResult;
      }
    }
    if (widget.confirmPasswordController != null &&
        widget.confirmPasswordController!.text != value) {
      return 'Passwords do not match';
    }
    return null;
  }
}
