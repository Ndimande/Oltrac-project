import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StripButton extends StatelessWidget {
  final Function onPressed;
  final Icon icon;
  final String labelText;
  final bool disabled;
  final Color color;
  final bool centered;

  StripButton(
      {@required this.icon,
      @required this.labelText,
      @required this.onPressed,
      this.color,
      this.disabled = false,
      this.centered = false});

  @override
  Widget build(BuildContext context) {
    final buttonColor = disabled ? Colors.grey : color;
    return Container(
      decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: null, color: buttonColor),
      height: 48,
      child: FlatButton(
        color: buttonColor,
        padding: const EdgeInsets.all(0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: <Widget>[
              icon,
              SizedBox(
                width: 5,
              ),
              Text(
                labelText,
                style: TextStyle(fontSize: 22, color: Colors.white),
              )
            ],
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
