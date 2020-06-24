import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';

class MasterContainerIcon extends StatelessWidget {
  final int indexNumber;

  const MasterContainerIcon({this.indexNumber});

  Widget _containerIcon() {
    return const Icon(
      Icons.inbox,
      color: OlracColours.fauxPasBlue,
      size: 64,
    );
  }

  Widget _indexNumber() {
    return Builder(builder: (BuildContext context) {
      return Container(
        margin: const EdgeInsets.only(top: 15, left: 26),
        child: Text(
          indexNumber.toString(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.bold),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _containerIcon(),
        _indexNumber(),
      ],
    );
  }
}
