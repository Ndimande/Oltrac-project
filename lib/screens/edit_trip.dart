import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/messages.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/datetime_editor.dart';
import 'package:oltrace/widgets/location_editor.dart';
import 'package:oltrace/widgets/strip_button.dart';

enum EditTripResult {
  Canceled,
  TripCanceled,
  Updated,
}

class EditTripScreen extends StatefulWidget {
  final _tripRepo = TripRepository();
  final Trip _trip;
  final bool _hasActiveHaul;

  EditTripScreen(this._trip)
      : _hasActiveHaul =
            _trip.hauls.singleWhere((Haul h) => h.endedAt == null, orElse: () => null) == null ? false : true;

  @override
  State<StatefulWidget> createState() => EditTripScreenState(
        _trip.startedAt,
        _trip.endedAt,
        _trip.startLocation,
        _trip.endLocation,
        _hasActiveHaul,
      );
}

class EditTripScreenState extends State<EditTripScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime _startDateTime;
  DateTime _endDateTime;
  Location _startLocation;
  Location _endLocation;
  final bool _hasActiveHaul;

  EditTripScreenState(
      this._startDateTime, this._endDateTime, this._startLocation, this._endLocation, this._hasActiveHaul)
      : assert(_startDateTime != null),
        assert(_startLocation != null);

  get title => Text('Edit Trip ${widget._trip.id}');

  Future<void> _onPressDeleteTrip() async {
    if (_hasActiveHaul) {
      showTextSnackBar(_scaffoldKey, 'You must first end the active haul');
      return;
    }

    final bool confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog('Delete Trip', 'Are you sure you want to delete the trip?'),
    );
    if (confirmed == true) {
      await widget._tripRepo.delete(widget._trip.id);
      Navigator.pop(_scaffoldKey.currentContext, EditTripResult.TripCanceled);
    }
  }

  void _onPressCancel() {
    Navigator.pop(context);
  }

  Future<void> _onPressSave() async {
    final List<String> validationErrors = [];
    // check that started time is not in future
    if (_startDateTime.isAfter(DateTime.now())) {
      validationErrors.add('Start time must be in the past');
    }

    if (validationErrors.length != 0) {
      showTextSnackBar(_scaffoldKey, validationErrors.join("\n"));
      return;
    }

    final updatedTrip = widget._trip.copyWith(
      startedAt: _startDateTime,
      startLocation: _startLocation,
      endLocation: _endLocation,
    );
    await widget._tripRepo.store(updatedTrip);

    Navigator.of(_scaffoldKey.currentContext).pop(EditTripResult.Updated);
  }

  Widget get _deleteTripButton => StripButton(
        onPressed: _onPressDeleteTrip,
        labelText: 'Delete Trip',
        icon: Icon(
          Icons.delete,
          color: Colors.white,
        ),
        color: Colors.red,
      );

  Widget get _cancelButton => StripButton(
    onPressed: _onPressCancel,
    labelText: 'Cancel',
    icon: Icon(
      Icons.cancel,
      color: Colors.white,
    ),
    color: OlracColours.olspsBlue,
  );

  Widget get _saveButton => StripButton(
        onPressed: _onPressSave,
        labelText: 'Save',
        icon: Icon(
          Icons.save,
          color: Colors.white,
        ),
        color: Colors.green,
      );

  Widget get _startSection {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        //Section heading
        Container(
          child: Text('Trip Start', style: TextStyle(color: OlracColours.olspsBlue, fontSize: 28)),
        ),
        SizedBox(height: 15),
        // Start DateTime
        DateTimeEditor(
          title: Text('Date & Time', style: TextStyle(color: OlracColours.olspsBlue, fontSize: 18)),
          initialDateTime: _startDateTime,
          onChanged: (Picker picker, List<int> selectedIndices) {
            setState(() {
              _startDateTime = DateTime.parse(picker.adapter.toString());
            });
          },
        ),

        // Start Location
        LocationEditor(
          title: Text('Location', style: TextStyle(color: OlracColours.olspsBlue, fontSize: 18)),
          onChanged: (Location location) {
            assert(location != null);
            setState(() {
              _startLocation = location;
            });
          },
          location: _startLocation,
        ),
      ],
    );
  }

  Widget get _endSection {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(child: Text('End', style: TextStyle(color: OlracColours.olspsBlue))),

        LocationEditor(
          onChanged: (Location location) {
            setState(() {
              _endLocation = location;
            });
          },
          location: _endLocation,
          title: Text('End Location', style: TextStyle(fontSize: 18)),
        ),
        // End DateTime
        DateTimeEditor(
          title: Text('End'),
          initialDateTime: _endDateTime,
          onChanged: (Picker picker, List<int> selectedIndices) {
            setState(() {
              _endDateTime = DateTime.parse(picker.adapter.toString());
            });
          },
        ),
      ],
    );
  }

  Widget get _bottomButtons {
    return Row(
      children: <Widget>[
        Expanded(
          child: _saveButton,
        ),
        Expanded(
          child: _cancelButton,
        ),
        Expanded(
          child: _deleteTripButton,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: title,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(15),
              child: Column(
                children: <Widget>[
                  _startSection,
                  _endLocation == null ? Container() : _endSection,
                ],
              ),
            ),
          ),
          _bottomButtons
        ],
      ),
    );
  }
}
