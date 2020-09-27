import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Color color;
  final String text;
  final double fontSize;
  final GestureTapCallback onTap;

  CustomButton({@required this.text, this.onTap, this.color, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100))),
        color: color ?? Colors.blue,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.white)),
        ),
      ),
    );
  }
}
