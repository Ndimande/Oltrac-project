import 'package:flutter/material.dart';

class BigButton extends StatelessWidget {
  final onPressed;
  final String label;

  BigButton({this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      buttonColor: Colors.blueGrey,
      minWidth: 280.0,
      height: 100.0,
      child: RaisedButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
      ),
    );
  }
}
