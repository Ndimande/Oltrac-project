import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/framework/util.dart';

class DateTimeEditor extends StatelessWidget {
  final DateTime initialDateTime;
  final Function onChanged;
  final Text title;

  DateTimeEditor({
    @required this.title,
    @required this.initialDateTime,
    @required this.onChanged,
  })  : assert(title != null),
        assert(initialDateTime != null),
        assert(onChanged != null);

  _onPressEditStartDateTime(BuildContext context) {
    final adapter = DateTimePickerAdapter(
      type: PickerDateTimeType.kYMDHM,
      value: initialDateTime,
      maxValue: DateTime.now(),
      minValue: DateTime.now().subtract(AppConfig.MAX_HISTORY_SELECTABLE),
    );

    Picker(
      selecteds: [],
      adapter: adapter,
      title: Text(title.data),
      onConfirm: (Picker picker, List<int> selectedIndices) => onChanged(picker, selectedIndices),
    ).showModal(context);
  }

//  final DateTime
  @override
  Widget build(BuildContext context) {
    return Container(
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[350],width: 2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          title,
          Row(
            children: <Widget>[
              FlatButton(
                padding: EdgeInsets.all(0),
                child: Text(
                  friendlyDateTime(initialDateTime),
                  style: TextStyle(fontSize: 28),
                ),
                onPressed: () => _onPressEditStartDateTime(context),
              )
            ],
          ),
        ],
      ),
    );
  }
}
