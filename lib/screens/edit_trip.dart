import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/widgets/datetime_editor.dart';
import 'package:oltrace/widgets/location_editor.dart';

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
      : _hasActiveHaul = !(_trip.hauls.singleWhere((Haul h) => h.endedAt == null, orElse: () => null) == null);

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

  Text get title => Text('Edit Trip ${widget._trip.id}');

  Future<void> _onPressDeleteTrip() async {
    if (_hasActiveHaul) {
      showTextSnackBar(_scaffoldKey, 'You must first end the active haul');
      return;
    }

    final bool confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const WestlakeConfirmDialog('Delete Trip', 'Are you sure you want to delete the trip?'),
    );
    if (confirmed == true) {
      await widget._tripRepo.delete(widget._trip.id);
      // Pop twice because the Trip is gone now so we can't render it.
      Navigator.pop(_scaffoldKey.currentContext);
      Navigator.pop(_scaffoldKey.currentContext);
    }
  }

  void _onPressCancel() {
    Navigator.pop(context);
  }

  Future<void> _onPressSave() async {
    final bool confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const WestlakeConfirmDialog('Update Trip', 'Are you sure you want to update the trip?'),
    );

    if (!confirmed) {
      return;
    }

    final List<String> validationErrors = [];
    // check that started time is not in future
    if (_startDateTime.isAfter(DateTime.now())) {
      validationErrors.add('Start time must be in the past');
    }

    if (validationErrors.isNotEmpty) {
      showTextSnackBar(_scaffoldKey, validationErrors.join('\n'));
      return;
    }

    final updatedTrip = widget._trip.copyWith(
      startedAt: _startDateTime,
      startLocation: _startLocation,
      endedAt: _endDateTime,
      endLocation: _endLocation,
    );
    await widget._tripRepo.store(updatedTrip);

    Navigator.of(_scaffoldKey.currentContext).pop();
  }

  Widget get _deleteTripButton => StripButton(
        onPressed: _onPressDeleteTrip,
        labelText: 'Delete',
        icon: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
        color: OlracColours.ninetiesRed,
      );

  Widget get _cancelButton => StripButton(
        onPressed: _onPressCancel,
        labelText: 'Cancel',
        icon: const Icon(
          Icons.cancel,
          color: Colors.white,
        ),
        color: OlracColours.fauxPasBlue,
      );

  Widget get _saveButton => StripButton(
        onPressed: _onPressSave,
        labelText: 'Save',
        icon: const Icon(
          Icons.save,
          color: Colors.white,
        ),
        color: OlracColours.ninetiesGreen,
      );

  Widget _section({
    String heading,
    DateTime dateTime,
    Location location,
    Function(Picker, List<int>) onDateTimeChanged,
    Function(Location) onLocationChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //Section heading
          Container(
            child: Text(heading, style: Theme.of(context).accentTextTheme.headline5),
          ),
          const SizedBox(height: 15),
          // Start DateTime
          DateTimeEditor(
            title: 'Date & Time',
            initialDateTime: dateTime,
            onChanged: onDateTimeChanged,
          ),

          // Start Location
          LocationEditor(
            title: 'Location',
            onChanged: onLocationChanged,
            location: location,
          ),
        ],
      ),
    );
  }

  Widget _tripStartSection() {
    return _section(
      heading: 'Trip Start',
      dateTime: _startDateTime,
      location: _startLocation,
      onDateTimeChanged: (Picker picker, List<int> selectedIndices) {
        setState(() {
          _startDateTime = DateTime.parse(picker.adapter.toString());
        });
      },
      onLocationChanged: (Location location) {
        assert(location != null);
        setState(() {
          _startLocation = location;
        });
      },
    );
  }

  Widget _endTripSection() {
    return _section(
      heading: 'Trip End',
      dateTime: _endDateTime,
      location: _endLocation,
      onDateTimeChanged: (Picker picker, List<int> selectedIndices) {
        setState(() {
          _endDateTime = DateTime.parse(picker.adapter.toString());
        });
      },
      onLocationChanged: (Location location) {
        setState(() {
          _endLocation = location;
        });
      },
    );
  }

  Widget get _bottomButtons {
    return Row(
      children: <Widget>[
        Expanded(child: _saveButton),
        Expanded(child: _deleteTripButton),
        Expanded(child: _cancelButton),
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
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: <Widget>[
                    _tripStartSection(),
                    if (widget._trip.isComplete)
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          _endTripSection(),
                        ],
                      )
                  ],
                ),
              ),
            ),
          ),
          _bottomButtons
        ],
      ),
    );
  }
}
