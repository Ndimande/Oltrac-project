import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/elapsed_counter.dart';
import 'package:oltrace/widgets/forward_arrow.dart';
import 'package:oltrace/widgets/time_ago.dart';

const double titleFontSize = 16;

class HaulListItem extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  final Haul _haul;
  final Function _onPressed;
  final int _listIndex;

  final sharedPrefs = SharedPreferencesProvider().sharedPreferences;

  Widget get temporal => _haul.endedAt == null ? durationCounter : endedAgo;

  Widget get title => temporal;

  HaulListItem(this._haul, this._onPressed, this._listIndex);

  ElapsedCounter get durationCounter =>
      ElapsedCounter(prefix: 'Duration: ', startedDateTime: _haul.startedAt,textStyle: TextStyle(fontSize: titleFontSize),);

  TimeAgo get endedAgo => TimeAgo(prefix: 'Ended ', dateTime: _haul.endedAt,textStyle: TextStyle(fontSize: titleFontSize),);

  bool get isActiveHaul => _appStore.activeHaul?.id == _haul.id;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlatButton(
        onPressed: _onPressed,
        child: ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _listIndex.toString(),
                style: TextStyle(fontSize: 24,color: olracBlue),
              ),
            ],
          ),
//            title: cardTitle,
          title: title,
          trailing: ForwardArrow(),
        ),
      ),
    );
  }
}
