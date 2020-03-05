import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/widgets/strip_button.dart';

class EditTripScreen extends StatefulWidget {
  final Trip tripArg;

  EditTripScreen(this.tripArg);

  @override
  State<StatefulWidget> createState() => EditTripScreenState(tripArg.startedAt);
}

class EditTripScreenState extends State<EditTripScreen> {
  DateTime _selectedDateTime;

  EditTripScreenState(this._selectedDateTime);

  get title => Text('Edit Trip ${widget.tripArg.id}');

  _onConfirmDateTime(DateTime date) {
    setState(() {
      _selectedDateTime = date;
    });
  }

  _onPressEditStartDateTime() {
    DatePicker.showDateTimePicker(
      context,
      maxTime: DateTime.now(),
      onConfirm: _onConfirmDateTime,
      currentTime: _selectedDateTime,
    );
  }

  Widget dateTimeEditor({
    String labelText,
    DateTime dateTime,
    onPressEdit,
  }) {
    return Container(
      child: Row(
        children: <Widget>[
          Text('Started '),
          Text(friendlyDateTime(_selectedDateTime)),
          FlatButton(
            child: Text('Edit'),
            onPressed: _onPressEditStartDateTime,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: dateTimeEditor(),
            ),
          ),
          StripButton(
            onPressed: () {},
            centered: true,
            labelText: 'Save',
            icon: Icon(
              Icons.save,
              color: Colors.white,
            ),
            color: Colors.green,
          )
        ],
      ),
    );
  }
}
