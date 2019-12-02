import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/data/species.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/species.dart';
import 'package:oltrace/models/tag.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';

class TagScreen extends StatefulWidget {
  final AppStore _appStore;

  TagScreen(this._appStore);

  @override
  State<StatefulWidget> createState() => TagScreenState();
}

class TagScreenState extends State<TagScreen> {
  String _tagCode;
  Species _selectedSpecies;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();

  TagScreenState();

  Widget buildRfid() {
    final String tagCodeText = _tagCode ?? 'No tag scanned';

    return Container(
      child: Column(
        children: <Widget>[
          Text('Tag code:'),
          Text(
            tagCodeText,
            style: TextStyle(fontSize: 28),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    FlutterNfcReader.onTagDiscovered().listen((NfcData onData) {
      setState(() {
        _tagCode = onData.id;
      });
    });

    super.initState();
  }

  _onPressSaveButton(haul, context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          ConfirmDialog('Confirm', 'Are you sure you want to save the tag?'),
    );

    if (!confirmed) {
      return;
    }

    final tag = await widget._appStore.saveTag(
      Tag(
        tagCode: _tagCode,
        species: _selectedSpecies,
        createdAt: DateTime.now(),
        weight: int.parse(_weightController.value.text) * 1000, // kg -> g
        length: int.parse(_lengthController.value.text),
        haulId: haul.id,
      ),
    );
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppConfig.primarySwatch,
      content: Text(
        'Tag ${tag.id.toString()} saved',
        style: TextStyle(fontSize: 30),
      ),
    ));
  }

  _floatingActionButton(Haul haul, context) {
    return Container(
      margin: EdgeInsets.only(top: 100),
      height: 65,
      width: 180,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        label: Text(
          'Save',
          style: TextStyle(fontSize: 22),
        ),
        icon: Icon(Icons.save),
        onPressed: () async => await _onPressSaveButton(haul, context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Haul haul = ModalRoute.of(context).settings.arguments;
    // todo sort this

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConfig.backgroundColor,
      floatingActionButton: _floatingActionButton(haul, context),
      appBar: AppBar(
        title: Text('Haul ${haul.id} - Create Tag'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildRfid(),
              Text(
                'Haul ${haul.id}',
              ),
              _speciesDropdown(_selectedSpecies, (Species species) {
                setState(() {
                  _selectedSpecies = species;
                });
              }),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Weight (kg)',
                    labelStyle: TextStyle(color: Colors.white)),
                controller: _weightController,
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Length (cm)',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                controller: _lengthController,
              ),
              RaisedButton(
                child: Text('Fake RFID scan'),
                onPressed: () => setState(() {
                  _tagCode = '0xFA7E5C46';
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget _speciesDropdown(Species _selected, Function _onChanged) {
  return DropdownButton<Species>(
    hint: Text('Select species'),
    value: _selected,
    onChanged: _onChanged,
    items: species.map<DropdownMenuItem<Species>>(
      (Species species) {
        return DropdownMenuItem<Species>(
          value: species,
          child: Text(
            species.englishName,
            style: TextStyle(color: Colors.black),
          ),
        );
      },
    ).toList(),
  );
}
