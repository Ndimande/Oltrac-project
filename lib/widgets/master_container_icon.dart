import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';

class MasterContainerIcon extends StatelessWidget {
  final int indexNumber;
  const MasterContainerIcon({this.indexNumber});

  Widget _containerIcon() {
    return Icon(
      Icons.inbox,
      color: OlracColours.fauxPasBlue,
      size: 50,
    );
  }

  Widget _indexNumber() {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 20),
      child: Text(
        indexNumber.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22,color: OlracColours.fauxPasBlue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[_containerIcon(), _indexNumber()],
    );
  }
}
