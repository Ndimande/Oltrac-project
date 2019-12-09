import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';

class ModelDropdown<T> extends StatelessWidget {
  final T selected;

  final Function onChanged;

  final items;

  final String label;

  final String hint;

  ModelDropdown({
    @required this.label,
    this.hint,
    @required this.selected,
    @required this.onChanged,
    @required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(fontSize: 20),
          ),
          DropdownButton<T>(
            hint: Text(
              hint ?? 'Tap to select',
              style: TextStyle(fontSize: 22, color: AppConfig.primarySwatchDark),
            ),
            isExpanded: true,
            style: TextStyle(fontSize: 22, color: Colors.white),
            value: selected,
            onChanged: onChanged,
            items: items,
          )
        ],
      ),
    );
  }
}
