import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StaticHaulDetailsAlertDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSuccesfulValidate;
  final Function onPressCancel;

  const StaticHaulDetailsAlertDialog({this.onSuccesfulValidate, this.onPressCancel});

  @override
  _StaticHaulDetailsAlertDialogState createState() => _StaticHaulDetailsAlertDialogState();
}

class _StaticHaulDetailsAlertDialogState extends State<StaticHaulDetailsAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _soakTimeHoursController = TextEditingController();
  final TextEditingController _soakTimeMinutesController = TextEditingController();
  final TextEditingController _numberOfTrapsOrHooksController = TextEditingController();

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

  Widget _soakTime() {
    final Widget hours = _alertInput(
      label: 'Hours',
      validate: _validateSoakHours,
      controller: _soakTimeHoursController,
    );
    final Widget minutes = _alertInput(
      label: 'Minutes',
      validate: _validateSoakMinutes,
      controller: _soakTimeMinutesController,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Soak Time'),
        const SizedBox(height: 5),
        Row(
          children: <Widget>[
            Expanded(child: hours),
            const SizedBox(width: 10),
            Expanded(child: minutes),
          ],
        ),
      ],
    );
  }

  Widget _numberOfTrapsOrHooks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Traps / Hooks'),
        const SizedBox(height: 5),
        _alertInput(
          label: 'Total number on gear',
          validate: _validateNumberOfTrapsHooks,
          controller: _numberOfTrapsOrHooksController,
        ),
      ],
    );
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
    const actionTextStyle = TextStyle(fontSize: 22, color: Colors.white);
    return <Widget>[
      FlatButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            final int soakTimeHours = int.parse(_soakTimeHoursController.text);
            final int soakTimeMinutes = int.parse(_soakTimeMinutesController.text);
            final Duration soakDuration = Duration(hours: soakTimeHours, minutes: soakTimeMinutes);

            final int numberOfTrapsOrHooks = int.parse(_numberOfTrapsOrHooksController.text);

            widget.onSuccesfulValidate(
                <String, dynamic>{'soakDuration': soakDuration, 'numberOfTrapsOrHooks': numberOfTrapsOrHooks});
          }
        },
        child: const Text('Start', style: actionTextStyle),
      ),
      FlatButton(
        onPressed: () => Navigator.pop(context, null),
        child: const Text('Cancel', style: actionTextStyle),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Haul Gear'),
      scrollable: true,
      content: _content(),
      actions: _actions(),
    );
  }
}

Widget _alertInput({String label, Function(String) validate, TextEditingController controller}) => TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 20),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(0),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
      validator: validate,
      cursorColor: Colors.white,
    );
