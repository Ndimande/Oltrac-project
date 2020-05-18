import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';

class ModelDropdown<T> extends StatelessWidget {
  final T selected;

  final Function onChanged;

  final items;

  final String label;

  final String hint;

  final TextStyle labelStyle;

  ModelDropdown({
    @required this.label,
    labelStyle,
    this.hint,
    @required this.selected,
    @required this.onChanged,
    @required this.items,
  }) : this.labelStyle = labelStyle ?? TextStyle(fontSize: 20, color: OlracColours.olspsBlue);

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: labelStyle,
          ),
          DropdownButton<T>(
            hint: Text(
              hint ?? 'Tap to select',
              style: const TextStyle(fontSize: 22),
            ),
            isExpanded: true,
            style: TextStyle(fontSize: 22, color: Colors.black),
            value: selected,
            onChanged: onChanged,
            items: items,
          )
        ],
      ),
    );
  }
}
