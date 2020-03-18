import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/repositories/haul.dart';
import 'package:oltrace/repositories/landing.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/grouped_hauls_list.dart';
import 'package:oltrace/widgets/numbered_boat.dart';
import 'package:oltrace/widgets/strip_button.dart';
import 'package:oltrace/widgets/time_space.dart';

final _tripRepo = TripRepository();
final _haulRepo = HaulRepository();
final _landingRepo = LandingRepository();
final _productRepo = ProductRepository();

//Future<File> _writeJson(String json) async {
//  final dir = await getApplicationDocumentsDirectory();
//  final path = dir.path;
//  print('write json to $path');
//  final file = File('$path/test.json');
//  final db = DatabaseProvider().database;
////  await db.insert('json', {'key': 'tripeg','json':json});
//  final sp = SharedPreferencesProvider().sharedPreferences;
//  sp.setString('tripeg', json);
//  // Write the file.
//  return file.writeAsString(json);
//}

Future<Trip> _getWithNested(Trip trip) async {
  List<Haul> activeTripHauls = await _haulRepo.forTripId(trip.id);
  final List<Haul> hauls = [];
  for (Haul haul in activeTripHauls) {
    final List<Landing> landings = await _landingRepo.forHaul(haul);
    final List<Landing> landingsWithProducts = [];
    for (Landing landing in landings) {
      final List<Product> products = await _productRepo.forLanding(landing.id);
      landingsWithProducts.add(landing.copyWith(products: products));
    }
    hauls.add(haul.copyWith(landings: landingsWithProducts));
  }
  final Trip tripWithNested = trip.copyWith(hauls: hauls);
//  await _writeJson(tripWithNested.toJson());
  return tripWithNested;
}

Future<Map<String, dynamic>> _load(int tripId) async {
  final Trip trip = await _getWithNested(await _tripRepo.find(tripId));
  final Trip activeTrip = await _tripRepo.getActive();
  return {
    'trip': trip,
    'isActiveTrip': trip.id == activeTrip?.id,
  };
}

class TripScreen extends StatefulWidget {
  final Dio dio = Dio();
  final int tripId;

  TripScreen({this.tripId});

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
  Trip _trip;
  bool isActiveTrip;

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
                SizedBox(height: 5),
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
    final label = trip.isUploaded ? 'Uploaded' : 'Upload Trip';
    final Function onPress = trip.isUploaded ? null : () async => await onPressUpload(trip);
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

  Future<void> onPressUpload(Trip trip) async {
    print('Uploading trip');

    // You may not upload active trip
    assert(!isActiveTrip);

    if (uploading) {
      print('Already uploading');
      return;
    }

    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text('Uploading Trip...'),
        duration: Duration(minutes: 20), // keep open
      ),
    );

    final Map<String, dynamic> data = {
      'datetimereceived': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'json': {
        'trip': trip.toMap(),
        'user': _appStore.profile.toMap(),
      }
    };

    print('Data:');
    print(data.toString());

    setState(() {
      uploading = true;
    });
    try {
      // Accept self signed cert
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
      final String json = jsonEncode(data);
      Response response = await dio.post(
        AppConfig.TRIP_UPLOAD_URL,
        data: json,
        options: RequestOptions(headers: {'Content-Type': 'application/json'}),
      );
      print('Response:');
      print(response.toString());

      await _tripRepo.store(trip.copyWith(isUploaded: true));

      print('Trip uploaded');
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Trip upload complete'),
        ),
      );
    } catch (e) {
      print('Error:');
      print(e.toString());
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Trip upload failed.\n' + e.toString()),
        ),
      );
    }

    setState(() {
      uploading = false;
    });
  }

  Text get title => Text(isActiveTrip ? 'Active Trip' : 'Completed Trip');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _load(widget.tripId),
      initialData: null,
      builder: (BuildContext buildContext, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Scaffold(body: Text(snapshot.error.toString()));
        }
        // Show blank screen until ready
        if (!snapshot.hasData) {
          return Scaffold();
        }

        _trip = snapshot.data['trip'];
        isActiveTrip = snapshot.data['isActiveTrip'];

        final mainButton = isActiveTrip ? Container() : uploadButton(_trip);
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: title),
          body: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildTripInfo(_trip),
                Expanded(
                  child: _trip.hauls.length > 0
                      ? GroupedHaulsList(
                          hauls: _trip.hauls.reversed.toList(),
                          onPressHaulItem: (int id, int index) async {
                            await Navigator.pushNamed(context, '/haul', arguments: {'haulId': id, 'listIndex': index});
                            setState(() {});
                          },
                        )
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
