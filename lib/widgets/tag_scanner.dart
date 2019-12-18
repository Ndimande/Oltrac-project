import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';

class TagScanner extends StatefulWidget {
  final Function onScan;

  TagScanner({this.onScan});

  @override
  State<StatefulWidget> createState() => TagScannerState();
}

class TagScannerState extends State<TagScanner> {
  String _tagCode;
  bool _enableScanning = false;

  @override
  void initState() {
    super.initState();
    FlutterNfcReader.onTagDiscovered().listen((NfcData onData) {
      if (_enableScanning) {
        setState(() {
          _tagCode = onData.id;
          widget.onScan(_tagCode);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Tag Code'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(_tagCode ?? '-'),
            FlatButton.icon(
              color: _enableScanning ? Colors.green : null,
              label: Text('Scan'),
              icon: Icon(Icons.nfc),
              onPressed: () => setState(() => _enableScanning = !_enableScanning),
            )
          ],
        )
      ],
    );
  }
}
