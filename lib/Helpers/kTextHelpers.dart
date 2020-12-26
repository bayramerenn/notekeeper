import 'package:flutter/material.dart';

Text buildTextHelpers(
    {String text,
    double size,
    Color color = Colors.black,
    FontWeight fontW = FontWeight.bold}) {
  return Text(
    text,
    style: TextStyle(
      color: color,
      fontSize: size,
      fontWeight: fontW,
    ),
  );
}
