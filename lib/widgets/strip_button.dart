import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';

class StripButton extends StatelessWidget {
  final Function onPressed;
  final Icon icon;
  final String labelText;
  final bool disabled;
  final Color color;

  StripButton({
    @required this.icon,
    @required this.labelText,
    @required this.onPressed,
    this.color = OlracColours.olspsBlue,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = disabled ? Colors.grey : color;
    return Container(
      decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: null, color: buttonColor),
      height: 48,
      child: FlatButton(
        color: buttonColor,
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if(icon != null) icon,
            SizedBox(width: 5),
            Expanded(
              child: Text(
                labelText,
                style: TextStyle(fontSize: 20, color: Colors.white),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
        onPressed: onPressed,
      ),
    );
  }
}
