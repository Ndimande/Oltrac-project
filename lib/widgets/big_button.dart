import 'package:flutter/material.dart';

class BigButton extends StatelessWidget {
  final onPressed;
  final Widget child;

  BigButton({this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      buttonColor: Colors.white,
      minWidth: 300.0,
      height: 150.0,
      child: RaisedButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
