import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/grouped_hauls_list.dart';
import 'package:oltrace/widgets/numbered_boat.dart';
import 'package:oltrace/widgets/strip_button.dart';
import 'package:oltrace/widgets/time_space.dart';

class TripScreen extends StatefulWidget {
  final Trip tripArg;

  TripScreen(this.tripArg);

  @override
  State<StatefulWidget> createState() {
    return TripScreenState();
  }
}

class TripScreenState extends State<TripScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final AppStore _appStore = StoreProvider().appStore;
  Dio dio = Dio();
  bool uploading = false;

  Widget _buildTripInfo(Trip trip) {
    return Container(
      color: olracBlue[50],
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          NumberedBoat(
            number: trip.id,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TimeSpace(label: 'Start', location: trip.startLocation, dateTime: trip.startedAt),
                SizedBox(
                  height: 5,
                ),
                trip.endedAt != null
                    ? TimeSpace(label: 'End', location: trip.endLocation, dateTime: trip.endedAt)
                    : Container(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget get noHauls => Container(
        alignment: Alignment.center,
        child: Text('No hauls on this trip', style: TextStyle(fontSize: 20)),
      );

  Widget uploadButton(Trip trip) {
    final label = trip.isUploaded ? 'Upload Complete' : 'Upload Trip';
    final Function onPress = trip.isUploaded ? null : () async => await onPressUploadTrip(trip);
    return StripButton(
      centered: true,
      labelText: label,
      disabled: trip.isUploaded,
      color: olracBlue,
      onPressed: onPress,
      icon: Icon(
        trip.isUploaded ? Icons.check_circle_outline : Icons.cloud_upload,
        color: Colors.white,
      ),
    );
  }

  onPressUploadTrip(Trip trip) async {
    // Don't upload if already uploading
    if (uploading) {
      return;
    }

    setState(() {
      uploading = true;
    });
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text('Uploading Trip...'),
        duration: Duration(minutes: 20), // keep open
      ),
    );
    try {
      final response = await _appStore.uploadTrip(trip);
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Trip upload complete'),
        ),
      );
    } catch (e) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Trip upload failed. Please check your connection.'),
        ),
      );
      print(e);
    }
    setState(() {
      uploading = false;
    });
  }

  Text get title =>
      Text(_appStore.activeTrip?.id == widget.tripArg.id ? 'Active Trip' : 'Completed Trip');

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final Trip trip = _appStore.findTrip(widget.tripArg.id);
        final mainButton = _appStore.hasActiveTrip && _appStore.activeTrip.id == trip.id
            ? Container()
            : uploadButton(trip);

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: title),
          body: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildTripInfo(trip),
                Expanded(
                  child: trip.hauls.length > 0
                      ? GroupedHaulsList(hauls: trip.hauls.reversed.toList())
                      : noHauls,
                ),
                mainButton
              ],
            ),
          ),
        );
      },
    );
  }
}
