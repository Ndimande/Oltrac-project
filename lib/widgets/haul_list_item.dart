import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/widgets/elapsed_counter.dart';
import 'package:oltrace/widgets/forward_arrow.dart';
import 'package:oltrace/widgets/haul_subtitle.dart';
import 'package:oltrace/widgets/time_ago.dart';

const double titleFontSize = 16;

class HaulListItem extends StatelessWidget {
  final Haul haul;
  final Function onPressed;
  final int listIndex;
  final bool usePlusIcon;

  HaulListItem({this.haul, this.onPressed, this.listIndex, this.usePlusIcon = false});

  Widget get temporal => haul.endedAt == null ? durationCounter : endedAgo;

  Widget get title => temporal;

  Widget get completeHaulTitle {
    return Text(
      'Ended ' + friendlyDateTime(haul.endedAt),
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget get activeHaulTitle {
    return Text(
      'Started ' + friendlyDateTime(haul.startedAt),
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  ElapsedCounter get durationCounter => ElapsedCounter(
        prefix: 'Duration: ',
        startedDateTime: haul.startedAt,
        style: TextStyle(fontSize: titleFontSize),
      );

  TimeAgo get endedAgo => TimeAgo(
        prefix: 'Ended ',
        dateTime: haul.endedAt,
        textStyle: TextStyle(fontSize: titleFontSize),
      );

  bool get isActiveHaul => haul.endedAt == null;

  Widget _trailing() {
    return usePlusIcon ? Icon(Icons.add_circle, color: OlracColours.olspsBlue, size: 38) : ForwardArrow();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(color: Colors.white, border: new Border(top: BorderSide(color: Colors.grey[300]))),
      child: ListTile(
        onTap: () => onPressed(listIndex),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              listIndex.toString(),
              style: TextStyle(fontSize: 28, color: OlracColours.olspsBlue),
            ),
          ],
        ),
        title: isActiveHaul ? activeHaulTitle : completeHaulTitle,
        subtitle: HaulSubtitle(
          startedAt: haul.startedAt,
          endedAt: haul.endedAt,
          totalWeight: haul.totalLandingWeight,
          totalProducts: haul.products.length,
        ),
        trailing: _trailing(),
      ),
    );
  }
}
