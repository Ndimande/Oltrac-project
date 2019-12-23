import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/elapsed_counter.dart';
import 'package:oltrace/widgets/time_ago.dart';

class HaulListItem extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  final Haul _haul;
  final Function onPressed;

  final sharedPrefs = SharedPreferencesProvider().sharedPreferences;

  HaulListItem(this._haul, this.onPressed);

  @override
  Widget build(BuildContext context) {
    final bool darkMode =
        sharedPrefs.getBool('darkMode') ?? AppConfig.defaultUserSettings['darkMode'];

    final String endedAt = friendlyDateTimestamp(_haul.endedAt);

    final startedAgo = ElapsedCounter(
      prefix: 'Duration: ',
      startedDateTime: _haul.startedAt,
    );

    final endedAgo = TimeAgo(
      prefix: 'Ended ',
      dateTime: _haul.endedAt,
    );

    final timePeriod = endedAt == null ? startedAgo : endedAgo;

    final bool isActiveHaul = _appStore.activeHaul?.id == _haul.id;

    final titleText = RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 18, color: darkMode ? Colors.white : Colors.black),
        children: <TextSpan>[
          TextSpan(
            text: 'Haul ${_haul.id}' + (isActiveHaul ? ' (Active)' : ''),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' - ${_haul.fishingMethod.name}'),
        ],
      ),
    );

    // The active Haul is decorated with a green bar on the left
    final decoration = isActiveHaul
        ? BoxDecoration(border: Border(left: BorderSide(width: 10, color: Colors.green)))
        : null;

    return Card(
      elevation: 2,
      child: Container(
        decoration: decoration,
        child: FlatButton(
          onPressed: onPressed,
          child: ListTile(
            title: titleText,
            subtitle: timePeriod,
            trailing: Icon(
              Icons.keyboard_arrow_right,
            ),
          ),
        ),
      ),
    );
  }
}
