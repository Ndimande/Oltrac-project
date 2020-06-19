import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/framework/util.dart';

class DateTimeEditor extends StatelessWidget {
  final DateTime initialDateTime;
  final Function onChanged;
  final String title;

  const DateTimeEditor({
    @required this.title,
    @required this.initialDateTime,
    @required this.onChanged,
  })  : assert(title != null),
        assert(initialDateTime != null),
        assert(onChanged != null);

  void _onPressEditStartDateTime(BuildContext context) {
    final adapter = DateTimePickerAdapter(
      type: PickerDateTimeType.kYMDHM,
      value: initialDateTime,
      maxValue: DateTime.now(),
      minValue: DateTime.now().subtract(AppConfig.MAX_HISTORY_SELECTABLE),
    );

    Picker(
      selecteds: [],
      adapter: adapter,
      title: Text(title, style: Theme.of(context).textTheme.subtitle1),
      onConfirm: (Picker picker, List<int> selectedIndices) => onChanged(picker, selectedIndices),
    ).showModal(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[350], width: 1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).accentTextTheme.headline6),
          FlatButton(
            padding: const EdgeInsets.all(0),
            onPressed: () => _onPressEditStartDateTime(context),
            child: Row(
              children: <Widget>[
                Text(
                  friendlyDateTime(initialDateTime),
                  style: Theme.of(context).textTheme.headline5,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
