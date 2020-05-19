import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/data/fishing_methods.dart';
import 'package:oltrace/data/svg_icons.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/widgets/svg_icon.dart';

const double iconBaseSize = 200;

class FishingMethodScreen extends StatelessWidget {
  Future<void> _onCardPressed(context, method) async {
    Navigator.pop(context, method);
  }

  Widget _buildFishingMethodCard(FishingMethod method) {
    final Widget svg = LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {

      return Container(
        child: SvgIcon(
          height: constraints.maxWidth * 0.4, // we have to use height for width because height constraint is infinite
          color: OlracColours.olspsDarkBlue,
          assetPath: SvgIcons.path(method.abbreviation),
        ),
      );
    });

    final child = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        svg,
        Column(
          children: <Widget>[
            Text(
              method.name,
              style: TextStyle(fontSize: 18, color: Colors.black),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '(${method.abbreviation})',
              style: TextStyle(fontSize: 18, color: OlracColours.olspsDarkBlue),
            ),
          ],
        )
      ],
    );
    return Builder(builder: (BuildContext context) {
      return Card(
        margin: const EdgeInsets.all(2),
        child: FlatButton(
          padding: const EdgeInsets.all(2),
          child: child,
          onPressed: () async => _onCardPressed(context, method),
        ),
      );
    });
  }

  dynamic chunk(list, int perChunk) =>
      list.isEmpty ? list : ([list.take(perChunk)]..addAll(chunk(list.skip(perChunk), perChunk)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Fishing Method')),
      body: Container(
        color: OlracColours.olspsBlue,
        padding: const EdgeInsets.all(2),
        child: OrientationBuilder(
          builder: (context, orientation) {
            final int columnCount = orientation == Orientation.portrait ? 2 : 4;
            final rows = chunk(fishingMethods, columnCount);

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: rows.map<Widget>((fms) {
                return Expanded(
                  child: Row(
                    children: fms.map<Widget>((FishingMethod fm) {
                      return Expanded(
                        child: _buildFishingMethodCard(fm),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
