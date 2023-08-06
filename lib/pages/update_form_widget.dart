import 'package:flutter/material.dart';

class UpdateFormWidget<T> extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final FormFieldValidator<T>? validator;
  final T? initialValue; // Add a variable to hold the initial value
  const UpdateFormWidget(
      {Key? key,
      required this.hintText,
      required this.obscureText,
      required this.validator,
      required this.initialValue,
      required this.onChanged // Pass the initial value to the constructor
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert the initial value to a string if not null
    String? initialText = initialValue != null ? initialValue.toString() : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        // Replace TextField with TextFormField

        initialValue: initialText, // Set the initial value here

        obscureText: obscureText,
        onChanged: onChanged, // Call the onChanged callback here

        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }
}
