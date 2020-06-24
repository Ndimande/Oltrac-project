//import 'package:flutter/material.dart';
//import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
//import 'package:olrac_themes/olrac_themes.dart';
//
//class TagScanner extends StatefulWidget {
//  final Function onScan;
//
//  const TagScanner({this.onScan});
//
//  @override
//  State<StatefulWidget> createState() => TagScannerState();
//}
//
//class TagScannerState extends State<TagScanner> {
//  String _tagCode;
//  bool _nfcReaderEnabled = false;
//
//  @override
//  void initState() {
//    super.initState();
//    try {
//      FlutterNfcReader.onTagDiscovered().listen((NfcData onData) {
//        if (_nfcReaderEnabled) {
//          setState(() {
//            _tagCode = onData.id;
//            widget.onScan(_tagCode);
//          });
//        }
//      });
//    } catch (e) {
//      print(e);
//    }
//  }
//
//  @override
//  void dispose() {
//    try {
//      FlutterNfcReader.stop();
//    } catch (e) {
//      print(e);
//    }
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Column(
//      children: <Widget>[
//        Text(
//          'Tag Code',
//          style: TextStyle(color: OlracColours.fauxPasBlue),
//        ),
//        Row(
//          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//          children: <Widget>[
//            Text(_tagCode ?? '-'),
//            FlatButton.icon(
//              color: _nfcReaderEnabled ? OlracColours.ninetiesGreen : null,
//              label: const Text('Scan'),
//              icon: Icon(Icons.nfc),
//              onPressed: () => setState(() => _nfcReaderEnabled = !_nfcReaderEnabled),
//            )
//          ],
//        )
//      ],
//    );
//  }
//}
