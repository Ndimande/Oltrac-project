import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/elapsed_counter.dart';
import 'package:oltrace/widgets/haul_list_item.dart';
import 'package:oltrace/widgets/screens/haul.dart';

class TripView extends StatelessWidget {
  final AppStore _appStore;
  final PageController _haulPageController;

  TripView(this._appStore, this._haulPageController);

  Widget _buildTripSection(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Trip ${_appStore.activeTrip.id}',
                style: TextStyle(fontSize: 32),
              ),
              Text('Started ' +
                  friendlyTimestamp(_appStore.activeTrip.startedAt)),
              Row(
                children: <Widget>[
                  Text(
                    'Status ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_appStore.activeHaul != null ? 'Hauling...' : 'At sea')
                ],
              ),
            ],
          ),
        ),
        _appStore.activeHaul != null
            ? Container()
            : Container(
                margin: EdgeInsets.only(right: 20),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  color: Colors.red,
                  child: Container(
                    height: 60,
                    width: 125,
                    padding: EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Icon(
                          Icons.stop,
                          color: Colors.white,
                        ),
                        Text(
                          'End Trip',
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  onPressed: () async {
                    bool confirmed = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => ConfirmDialog(
                        'End Trip',
                        'Are you sure you want to end the trip?',
                      ),
                    );
                    if (confirmed) {
                      await _appStore.endTrip();
                    }
                  },
                ),
              )
      ],
    );
  }

  Widget _buildHaulSection() {
    return PageView(
      controller: _haulPageController,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        _buildCompleteHaulsPage(),
        _buildActiveHaulPage(),
      ],
    );
  }

  Widget _buildNoActiveHaul() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        'No active haul.',
        style: TextStyle(fontSize: 26),
      ),
    );
  }

  Widget _buildHaulInfo() {
    final double labelFontSize = 18;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Haul ${_appStore.activeHaul.id}',
          style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Fishing Method:',
              style: TextStyle(fontSize: labelFontSize),
            ),
            Text(
              _appStore.activeHaul.fishingMethod.name,
              style: TextStyle(fontSize: 34),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text('Started: ', style: TextStyle(fontSize: labelFontSize)),
                Text(
                  friendlyTimestamp(_appStore.activeHaul.startedAt),
                  style: TextStyle(fontSize: 22),
                )
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text('Elapsed: ', style: TextStyle(fontSize: labelFontSize)),
                  ElapsedCounter(
                    _appStore.activeHaul.startedAt,
                    textStyle: TextStyle(fontSize: 22),
                  )
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildActiveHaulPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        // Links row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _appStore.activeTrip.hauls.length == 0
                ? Container(
                    height: 100,
                  )
                : Container(
                    child: FlatButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Icon(Icons.chevron_left,
                              color: AppConfig.primarySwatch),
                          Text(
                            'Completed Hauls',
                            style: TextStyle(color: AppConfig.primarySwatch),
                          ),
                        ],
                      ),
                      onPressed: () => _haulPageController.animateToPage(0,
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeInOutQuad),
                    ),
                  )
          ],
        ),
        // Info row
        Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.only(left: 5),
          child: _appStore.activeHaul == null
              ? _buildNoActiveHaul()
              : _buildHaulInfo(),
        )
      ],
    );
  }

  Widget _buildCompleteHaulsPage() {
    final List<Haul> hauls = _appStore.activeTrip.hauls;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 10),
                child: Text(
                  'Completed Hauls',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              _appStore.activeHaul == null
                  ? Container()
                  : Container(
                      child: FlatButton(
                        child: Row(
                          children: <Widget>[
                            Text(
                              'Active Haul',
                              style: TextStyle(color: AppConfig.primarySwatch),
                            ),
                            Icon(Icons.chevron_right,
                                color: AppConfig.primarySwatch),
                          ],
                        ),
                        onPressed: () async =>
                            await _haulPageController.animateToPage(
                          1,
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeInOutQuad,
                        ),
                      ),
                    ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            child: ListView.builder(
              itemCount: hauls.length,
              itemBuilder: (context, index) {
                final Haul haul = hauls[index];
                return HaulListItem(
                  haul,
                  () async => await _onPressHaulListItem(context, haul),
                );
              },
            ),
          ),
        )
      ],
    );
  }

  _onPressHaulListItem(context, Haul haul) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HaulScreen(_appStore),
        settings: RouteSettings(
          arguments: haul,
        ),
      ),
    );
  }

  Widget _buildNoActiveTrip(context) {
    return Container(
      alignment: Alignment.center,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              color: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                    Text(
                      'Start Trip',
                      style: TextStyle(color: Colors.white, fontSize: 28),
                    ),
                  ],
                ),
                height: 80,
                width: 200,
              ),
              onPressed: () async {
                bool confirmed = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => ConfirmDialog(
                    'Start Trip',
                    'Are you sure you want to start a new trip?',
                  ),
                );
                if (confirmed) {
                  await _appStore.startTrip();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_appStore.tripHasStarted) {
      return _buildNoActiveTrip(context);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          child: _buildTripSection(context),
          height: 100,
        ),
        Divider(),
        Expanded(child: _buildHaulSection()),
      ],
    );
  }
}
