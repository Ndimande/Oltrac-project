import 'dart:async';

import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/westlake/forward_arrow.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:olrac_widgets/westlake/westlake_list_item.dart';

class HaulListItem extends StatelessWidget {
  final Haul haul;
  final Function onPressed;
  final int listIndex;
  final bool usePlusIcon;

  const HaulListItem({
    this.haul,
    this.onPressed,
    this.listIndex,
    this.usePlusIcon = false,
  });

  Widget _title() {
    final String text =
        haul.isActive ? 'Started ' + friendlyDateTime(haul.startedAt) : 'Ended ' + friendlyDateTime(haul.endedAt);
    return Builder(builder: (BuildContext context) {
      return Text(
        text,
        style: Theme.of(context).textTheme.headline6,
      );
    });
  }

  Widget _subtitle() {
    return _HaulSubtitle(
      startedAt: haul.startedAt,
      endedAt: haul.endedAt,
      totalWeight: haul.totalLandingWeight,
      totalProducts: haul.products.length,
    );
  }

  Widget _leading() {
    return Builder(builder: (BuildContext context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            listIndex.toString(),
            style: Theme.of(context).primaryTextTheme.headline4,
          ),
        ],
      );
    });
  }

  Widget _trailing() {
    return usePlusIcon ? const Icon(Icons.add_circle, color: OlracColours.fauxPasBlue, size: 38) : const ForwardArrow();
  }

  @override
  Widget build(BuildContext context) {
    return WestlakeListItem(
      onPressed: () => onPressed(listIndex),
      leading: _leading(),
      title: _title(),
      subtitle: _subtitle(),
      trailing: _trailing(),
    );
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[300]))),
      child: ListTile(
        onTap: () => onPressed(listIndex),
        leading: _leading(),
        title: _title(),
        subtitle: _subtitle(),
        trailing: _trailing(),
      ),
    );
  }
}

class _HaulSubtitle extends StatefulWidget {
  static const _updateInterval = Duration(milliseconds: 1000);
  final DateTime startedAt;
  final DateTime endedAt;

  final int totalProducts;
  final int totalWeight;

  const _HaulSubtitle({
    @required this.totalProducts,
    @required this.totalWeight,
    @required this.startedAt,
    this.endedAt,
  })  : assert(totalProducts != null),
        assert(totalWeight != null);

  @override
  State<StatefulWidget> createState() => _HaulSubtitleState();
}

class _HaulSubtitleState extends State<_HaulSubtitle> {
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_HaulSubtitle._updateInterval, (Timer t) => setState(() {}));
  }

  double get _totalWeightKilograms => widget.totalWeight / 1000;

  String _getHours(Duration difference) => difference.inHours.toString();

  String _getMinutes(Duration difference) => (difference.inMinutes % 60).round().toString().padLeft(2, '0');

  String _getSeconds(Duration difference) => (difference.inSeconds % 60).round().toString().padLeft(2, '0');

  Duration get _elapsed {
    final DateTime endedAt = widget.endedAt;
    final DateTime startedAt = widget.startedAt;

    final DateTime until = endedAt ?? DateTime.now();
    return until.difference(startedAt);
  }

  TextSpan get elapsedTextSpan => TextSpan(
        text: '${_getHours(_elapsed)}h ${_getMinutes(_elapsed)}m ${_getSeconds(_elapsed)}s, ',
        style: Theme.of(context).textTheme.subtitle1,
      );

  TextSpan get _kilogramsTotal => TextSpan(
        text: ' ${_totalWeightKilograms.toStringAsFixed(2)}kg, ',
        style: Theme.of(context).textTheme.subtitle1,
      );

  TextSpan get _totalProducts {
    final int totalTags = widget.totalProducts;

    return TextSpan(
      text: '$totalTags tags',
      style: Theme.of(context).textTheme.subtitle1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: <TextSpan>[
        elapsedTextSpan,
        _kilogramsTotal,
        _totalProducts,
      ]),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
