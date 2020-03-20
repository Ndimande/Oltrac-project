import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/data/fishing_methods.dart';
import 'package:oltrace/data/svg_icons.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/svg_icon.dart';

const double iconBaseSize = 200;

double _getIconSize(MediaQueryData mediaQuery) {
  final height = mediaQuery.size.height;
  final width = mediaQuery.size.width;
  final orientation = mediaQuery.orientation;
  final ratio = orientation == Orientation.portrait ? width / height : height / width;
  return ratio * iconBaseSize;
}
class FishingMethodScreen extends StatelessWidget {
  _onCardPressed(context, method) async {
    bool answer = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
        ConfirmDialog(
          'Start Haul?', 'Are you sure you want to start a ${method.name.toLowerCase()} haul?'),
    );

    if (answer) {
      Navigator.pop(context, method);
    }
  }

  Widget _buildFishingMethodCard(FishingMethod method) {
    final Widget svg = Builder(builder: (context) {
      final double iconSize = _getIconSize(MediaQuery.of(context));
      return Container(
        height: iconSize,
        width: iconSize,
        child: SvgIcon(
          darker: true,
          assetPath: SvgIcons.path(method.name),
        ),
      );
    });

    final child = new Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        svg,
        Column(
          children: <Widget>[
            Text(
              method.name,
              style: TextStyle(fontSize: 18,color: Colors.black),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '(${method.abbreviation})',
              style: TextStyle(
                fontSize: 18,color: olracDarkBlue
              ),
            ),
          ],
        )
      ],
    );
    return Builder(builder: (BuildContext context) {
      return Card(
        margin: EdgeInsets.all(2),
        child: FlatButton(
          padding: EdgeInsets.all(2),
          child: child,
          onPressed: () async => _onCardPressed(context, method),
        ),
      );
    });
  }

  Widget get grid {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[],
        ),
      ],
    );
  }

  chunk(list, int perChunk) =>
    list.isEmpty ? list : ([list.take(perChunk)]..addAll(chunk(list.skip(perChunk), perChunk)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Fishing Method')),
      body: Container(
        color: olracBlue,
        padding: EdgeInsets.all(2),
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
      ));
  }
}
