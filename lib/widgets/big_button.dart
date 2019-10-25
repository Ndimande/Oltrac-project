import 'package:flutter/material.dart';

class BigButton extends StatelessWidget {
  final onPressed;
  final String label;

  BigButton({this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      buttonColor: Colors.indigo,
      minWidth: 300.0,
      height: 150.0,
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
