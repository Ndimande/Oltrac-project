import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
import 'package:olrac_widgets/westlake/westlake_text_input.dart';

class StaticHaulDetailsDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSuccesfulValidate;
  final Function onPressCancel;

  const StaticHaulDetailsDialog({this.onSuccesfulValidate, this.onPressCancel});

  @override
  _StaticHaulDetailsDialogState createState() {
    return _StaticHaulDetailsDialogState();
  }
}

class _StaticHaulDetailsDialogState extends State<StaticHaulDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _soakTimeHoursController = TextEditingController();
  final TextEditingController _soakTimeMinutesController = TextEditingController();
  final TextEditingController _numberOfTrapsOrHooksController = TextEditingController();

  Widget _soakTime() {
    final Widget hours = WestlakeTextInput(
      textAlign: TextAlign.center,
      counterText: 'Hours',
      validator: _validateSoakHours,
      controller: _soakTimeHoursController,
      brightness: Brightness.dark,
      keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
    );

    final Widget minutes = WestlakeTextInput(
      textAlign: TextAlign.center,
      counterText: 'Minutes',
      validator: _validateSoakMinutes,
      controller: _soakTimeMinutesController,
      brightness: Brightness.dark,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Soak Time', style: _labelStyle),
        const SizedBox(height: 5),
        Row(
          children: <Widget>[
            // Hours
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                color: Theme.of(context).accentColor,
                child: hours,
              ),
            ),

            const SizedBox(width: 10),

            // Minutes
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                color: Theme.of(context).accentColor,
                child: minutes,
              ),
            ),
          ],
        ),
      ],
    );
  }

  TextStyle get _labelStyle => Theme.of(context).textTheme.headline5.copyWith(color: Colors.white);

  Widget _numberOfTrapsOrHooks() {
    return Builder(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('No. of Traps/Hooks', style: _labelStyle),
          const SizedBox(height: 5),
          Container(
            margin: EdgeInsets.only(right: 50),
            padding: const EdgeInsets.all(5),
            color: Theme.of(context).accentColor,
            child: WestlakeTextInput(
              textAlign: TextAlign.center,
              validator: _validateNumberOfTrapsHooks,
              controller: _numberOfTrapsOrHooksController,
              brightness: Brightness.dark,
            ),
          ),
        ],
      );
    });
  }

  Widget _content() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _soakTime(),
          const SizedBox(height: 10),
          _numberOfTrapsOrHooks(),
        ],
      ),
    );
  }

  List<Widget> _actions() {
    return <Widget>[
      WestlakeDialogOption(
        text: 'Start',
        onPressed: () {
          if (_formKey.currentState.validate()) {
            final int soakTimeHours = int.parse(_soakTimeHoursController.text);
            final int soakTimeMinutes = int.parse(_soakTimeMinutesController.text);
            final Duration soakDuration = Duration(hours: soakTimeHours, minutes: soakTimeMinutes);

            final int numberOfTrapsOrHooks = int.parse(_numberOfTrapsOrHooksController.text);

            widget.onSuccesfulValidate(<String, dynamic>{
              'soakDuration': soakDuration,
              'numberOfTrapsOrHooks': numberOfTrapsOrHooks,
            });
          }
        },
      ),
      WestlakeDialogOption(
        text: 'Cancel',
        onPressed: () => Navigator.pop(context, null),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WestlakeDialog(
      title: 'Gear Information',
      content: _content(),
      actions: _actions(),
    );
  }
}

String _validateSoakHours(String value) {
  final int intVal = int.tryParse(value);
  if (intVal == null) {
    return 'Invalid number';
  }
  return null;
}

String _validateSoakMinutes(String value) {
  final int intVal = int.tryParse(value);
  if (intVal == null) {
    return 'Invalid number';
  } else if (intVal < 0 || intVal > 59) {
    return 'Max 59 minutes';
  }
  return null;
}

String _validateNumberOfTrapsHooks(String value) {
  final int intVal = int.tryParse(value);
  if (intVal == null) {
    return 'Invalid number';
  }
  return null;
}
