import 'package:flutter/material.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/time_ago.dart';

class HaulListItem extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  final Haul _haul;
  final Function onPressed;

  HaulListItem(this._haul, this.onPressed);

  @override
  Widget build(BuildContext context) {
    final String startedAt = friendlyDateTimestamp(_haul.startedAt);
    final String endedAt = friendlyDateTimestamp(_haul.endedAt);

    final ago = TimeAgo(
      prefix: 'Started ',
      startedAt: _haul.startedAt,
      textStyle: TextStyle(fontSize: 16),
    );

    final timePeriod =
        endedAt == null ? ago : Text('$startedAt - $endedAt', style: TextStyle(fontSize: 16));

    final bool isActiveHaul = _appStore.activeHaul?.id == _haul.id;

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          isActiveHaul
              ? 'Haul ${_haul.id} (Active) - ${_haul.fishingMethod.name}'
              : 'Haul ${_haul.id} - ${_haul.fishingMethod.name}',
          style: TextStyle(fontSize: 18),
        ),
      ],
    );

    return Card(
      elevation: 2,
      child: Container(
        decoration: isActiveHaul
            ? BoxDecoration(border: Border(left: BorderSide(width: 10, color: Colors.green)))
            : null,
        child: FlatButton(
          onPressed: onPressed,
          child: ListTile(
            title: title,
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
