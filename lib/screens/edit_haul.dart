import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/fishing_method_type.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/repositories/haul.dart';
import 'package:oltrace/widgets/datetime_editor.dart';
import 'package:oltrace/widgets/location_editor.dart';
import 'package:olrac_widgets/westlake/westlake_text_input.dart';

class EditHaul extends StatefulWidget {
  final Haul haul;

  const EditHaul({this.haul});

  @override
  _EditHaulState createState() => _EditHaulState(
        startLocation: haul.startLocation,
        endLocation: haul.endLocation,
        startDateTime: haul.startedAt,
        endDateTime: haul.endedAt,
        totalHooksOrTraps: haul.hooksOrTraps,
        soakTime: haul.soakTime,
      );
}

class _EditHaulState extends State<EditHaul> {
  _EditHaulState({
    this.startDateTime,
    this.endDateTime,
    this.startLocation,
    this.endLocation,
    int totalHooksOrTraps,
    Duration soakTime,
  })  : _hooksAndTrapsController = TextEditingController(text: totalHooksOrTraps.toString()),
        _soakHoursController = soakTime == null ? null : TextEditingController(text: soakTime.inHours.toString()),
        _soakMinutesController = soakTime == null ? null :TextEditingController(text: (soakTime.inMinutes % 60).toString());

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime startDateTime;
  DateTime endDateTime;
  Location startLocation;
  Location endLocation;
  final TextEditingController _hooksAndTrapsController;
  final TextEditingController _soakHoursController;
  final TextEditingController _soakMinutesController;

  Future<void> _onPressSave() async {
    final bool confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const WestlakeConfirmDialog('Update Haul', 'Are you sure you want to update the haul?'),
    );

    if (!confirmed) {
      return;
    }

    final List<String> validationErrors = [];
    // check that started time is not in future
    if (startDateTime.isAfter(DateTime.now())) {
      validationErrors.add('Start time must be in the past');
    }

    if (validationErrors.isNotEmpty) {
      showTextSnackBar(_scaffoldKey, validationErrors.join('\n'));
      return;
    }

    final Duration soakTime = Duration(
      hours: int.parse(_soakHoursController.text),
      minutes: int.parse(_soakMinutesController.text),
    );

    await HaulRepository().store(widget.haul.copyWith(
      startedAt: startDateTime,
      endedAt: endDateTime,
      startLocation: startLocation,
      endLocation: endLocation,
      hooksOrTraps: int.parse(_hooksAndTrapsController.text),
      soakTime: soakTime,
    ));
    Navigator.pop(context);
  }

  Future<void> _onPressDelete() async {
    final bool confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const WestlakeConfirmDialog('Delete Haul', 'Are you sure you want to delete the haul?'),
    );

    if (!confirmed) {
      return;
    }

    await HaulRepository().delete(widget.haul.id);
    // TODO delete dangling children in database
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Widget _startLocationEditor() {
    return LocationEditor(
      title: 'Start Location',
      location: startLocation,
      onChanged: (Location location) => setState(() => startLocation = location),
    );
  }

  Widget _endLocationEditor() {
    return LocationEditor(
      title: 'End Location',
      location: endLocation,
      onChanged: (Location location) => setState(() => endLocation = location),
    );
  }

  Widget _startDatetimeEditor() {
    return DateTimeEditor(
      title: 'Start Date & Time',
      initialDateTime: startDateTime,
      onChanged: (Picker picker, List<int> selectedIndices) {
        setState(() {
          startDateTime = DateTime.parse(picker.adapter.toString());
        });
      },
    );
  }

  Widget _endDatetimeEditor() {
    return DateTimeEditor(
      title: 'End Date & Time',
      initialDateTime: endDateTime,
      onChanged: (Picker picker, List<int> selectedIndices) {
        setState(() {
          endDateTime = DateTime.parse(picker.adapter.toString());
        });
      },
    );
  }

  Widget _soakTimeEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Soak Time',
          style: Theme.of(context).accentTextTheme.headline6,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: WestlakeTextInput(controller: _soakHoursController, counterText: 'Hours'),
            ),
            Expanded(
              child: WestlakeTextInput(controller: _soakMinutesController, counterText: 'Minutes'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _trapsAndHooksEditor() {
    return WestlakeTextInput(
      label: 'Hooks and Traps',
      controller: _hooksAndTrapsController,
    );
  }

  Widget _trapsAndHooks() {
    return Column(
      children: [
        _soakTimeEditor(),
        _trapsAndHooksEditor(),
      ],
    );
  }

  Widget _body() {
    return Builder(builder: (BuildContext context) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            _startLocationEditor(),
            if (widget.haul.endLocation != null) _endLocationEditor(),
            _startDatetimeEditor(),
            if (widget.haul.endedAt != null) _endDatetimeEditor(),
            if (widget.haul.fishingMethod.type == FishingMethodType.Static) _trapsAndHooks()
          ].map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: e)).toList(),
        ),
      );
    });
  }

  List<StripButton> _bottomButtons() {
    final StripButton saveButton = StripButton(
      onPressed: _onPressSave,
      labelText: 'Save',
      icon: const Icon(
        Icons.save,
        color: Colors.white,
      ),
      color: OlracColours.ninetiesGreen,
    );

    final StripButton deleteButton = StripButton(
      onPressed: _onPressDelete,
      labelText: 'Delete',
      icon: const Icon(
        Icons.delete,
        color: Colors.white,
      ),
      color: OlracColours.ninetiesRed,
    );

    return [
      saveButton,
      deleteButton,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WestlakeScaffold(
      title: 'Edit Haul',
      bottomButtons: _bottomButtons(),
      body: (BuildContext context, _) {
        return _body();
      },
    );
  }
}
