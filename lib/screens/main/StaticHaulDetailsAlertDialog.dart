import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StaticHaulDetailsAlertDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSuccesfulValidate;
  final Function onPressCancel;

  StaticHaulDetailsAlertDialog({this.onSuccesfulValidate, this.onPressCancel});

  @override
  _StaticHaulDetailsAlertDialogState createState() => _StaticHaulDetailsAlertDialogState();
}

class _StaticHaulDetailsAlertDialogState extends State<StaticHaulDetailsAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _soakTimeHoursController = TextEditingController();
  final TextEditingController _soakTimeMinutesController = TextEditingController();
  final TextEditingController _numberOfTrapsOrHooksController = TextEditingController();

  String _validateSoakHours(String value) {
    int intVal = int.tryParse(value);
    if (intVal == null) {
      return 'Invalid number';
    }
    return null;
  }

  String _validateSoakMinutes(String value) {
    int intVal = int.tryParse(value);
    if (intVal == null) {
      return 'Invalid number';
    }
    return null;
  }

  String _validateNumberOfTrapsHooks(String value) {
    int intVal = int.tryParse(value);
    if (intVal == null) {
      return 'Invalid number';
    }
    return null;
  }

  Widget _soakTime() {
    final Widget hours = _alertInput(label: 'Hours', validate: _validateSoakHours,
      controller: _soakTimeHoursController,
    );
    final Widget minutes = _alertInput(label: 'Minutes', validate: _validateSoakMinutes,
      controller: _soakTimeMinutesController,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Soak Time'),
        SizedBox(height: 5),
        Row(
          children: <Widget>[
            Expanded(child: hours),
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
        Text('Traps / Hooks'),
        SizedBox(height: 5),
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
          SizedBox(height: 10),
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

            widget.onSuccesfulValidate(<String,dynamic>{'soakDuration': soakDuration, 'numberOfTrapsOrHooks': numberOfTrapsOrHooks});
          }
        },
        child: Text(
          'Start',
          style: actionTextStyle,
        ),
      ),
      FlatButton(
        onPressed: () => Navigator.pop(context, null),
        child: Text(
          'Cancel',
          style: actionTextStyle,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: _content(),
      actions: _actions(),
    );
  }
}

Widget _alertInput({String label, Function(String) validate, TextEditingController controller}) => TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white, fontSize: 20),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(0),
        labelText: label,
        labelStyle: TextStyle(color: Colors.white, fontSize: 16),
      ),
      keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
      validator: validate,
      cursorColor: Colors.white,
    );
