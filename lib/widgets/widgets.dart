import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  focusedBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white12, width: 2)),
  errorBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)),
  border: OutlineInputBorder(gapPadding: 0.5),
  labelStyle: TextStyle(
      fontSize: 20, color: Colors.white70, fontWeight: FontWeight.w400),
);

void showSnackbar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: "OK",
        onPressed: () {},
        textColor: Colors.white,
      ),
    ),
  );
}
