import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/providers/shared_preferences.dart';

class ModelDropdown<T> extends StatelessWidget {
  final sharedPrefs = SharedPreferencesProvider().sharedPreferences;

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
  }) : this.labelStyle = labelStyle ?? TextStyle(fontSize: 20, color: olracBlue);

  @override
  Widget build(BuildContext context) {
    final bool darkMode =
        sharedPrefs.getBool('darkMode') ?? AppConfig.defaultUserSettings['darkMode'];

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
              style: TextStyle(fontSize: 22),
            ),
            isExpanded: true,
            style: TextStyle(fontSize: 22, color: darkMode ? Colors.white : Colors.black),
            value: selected,
            onChanged: onChanged,
            items: items,
          )
        ],
      ),
    );
  }
}
