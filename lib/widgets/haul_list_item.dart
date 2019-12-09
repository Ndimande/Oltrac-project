import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';

class HaulListItem extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  final Haul _haul;
  final Function onPressed;

  HaulListItem(this._haul, this.onPressed);

  @override
  Widget build(BuildContext context) {
    final String startedAt = friendlyTimestamp(_haul.startedAt);
    final String endedAt = friendlyTimestamp(_haul.endedAt);

    final timePeriodText = endedAt == null ? 'Started: $startedAt' : '$startedAt - $endedAt';
    final timePeriod = Text(timePeriodText, style: TextStyle(fontWeight: FontWeight.bold));

    final bool isActiveHaul = _appStore.activeHaul?.id == _haul.id;

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          isActiveHaul
              ? 'Haul ${_haul.id} (Active) - ${_haul.fishingMethod.name}'
              : 'Haul ${_haul.id} - ${_haul.fishingMethod.name}',
        ),
      ],
    );
    return Card(
      color: isActiveHaul ? AppConfig.accentColor : null,
      elevation: 2,
      child: FlatButton(
          onPressed: onPressed,
          child: ListTile(
            title: title,
            subtitle: timePeriod,
            trailing: Icon(
              Icons.keyboard_arrow_right,
            ),
          )),
    );
  }
}
