import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:oltrace/widgets/elapsed_counter.dart';
import 'package:oltrace/widgets/haul_subtitle.dart';
import 'package:oltrace/widgets/time_ago.dart';

const double titleFontSize = 16;

class HaulListItem extends StatelessWidget {
  final Haul haul;
  final Function onPressed;
  final int listIndex;

  final sharedPrefs = SharedPreferencesProvider().sharedPreferences;

  HaulListItem({this.haul, this.onPressed, this.listIndex});

  Widget get temporal => haul.endedAt == null ? durationCounter : endedAgo;

  Widget get title => temporal;

  Widget get completeHaulTitle {
    return Text(
      'End ' + friendlyDateTime(haul.endedAt),
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget get activeHaulTitle {
    return Text(
      'Start ' + friendlyDateTime(haul.startedAt),
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
              style: TextStyle(fontSize: 28, color: olracBlue),
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
        trailing: Icon(
          Icons.add_circle,
          color: olracBlue,
          size: 38,
        ),
      ),
    );
  }
}
