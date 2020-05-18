import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/repositories/haul.dart';
import 'package:oltrace/repositories/landing.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/screens/edit_trip.dart';
import 'package:oltrace/services/trip_upload.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/grouped_hauls_list.dart';
import 'package:oltrace/widgets/numbered_boat.dart';
import 'package:oltrace/widgets/strip_button.dart';
import 'package:oltrace/widgets/time_space.dart';

final _tripRepo = TripRepository();
final _haulRepo = HaulRepository();
final _landingRepo = LandingRepository();
final _productRepo = ProductRepository();

Future<Trip> _getWithNested(Trip trip) async {
  final List<Haul> activeTripHauls = await _haulRepo.forTrip(trip.id);
  final List<Haul> hauls = [];
  for (final Haul haul in activeTripHauls) {
    final List<Landing> landings = await _landingRepo.forHaul(haul.id);
    final List<Landing> landingsWithProducts = [];
    for (final Landing landing in landings) {
      final List<Product> products = await _productRepo.forLanding(landing.id);
      landingsWithProducts.add(landing.copyWith(landings: products));
    }
    hauls.add(haul.copyWith(landings: landingsWithProducts));
  }
  final Trip tripWithNested = trip.copyWith(hauls: hauls);

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
  final int tripId;

  const TripScreen({this.tripId});

  @override
  State<StatefulWidget> createState() {
    return TripScreenState();
  }
}

class TripScreenState extends State<TripScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _uploading = false;
  Trip _trip;
  bool isActiveTrip;

  Future<void> _onPressEditTrip() async {
    final EditTripResult result = await Navigator.push(
      _scaffoldKey.currentContext,
      MaterialPageRoute(builder: (_) => EditTripScreen(_trip)),
    );
    setState(() {});
    if (result == EditTripResult.TripCanceled && _trip.isComplete) {
      Navigator.pop(context);
    } else if (EditTripResult.Updated == result) {
      showTextSnackBar(_scaffoldKey, 'Trip updated');
    }
  }

  Widget _buildTripInfo(Trip trip) {
    return Column(
      children: <Widget>[
        Container(
          color: OlracColours.olspsBlue[50],
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              NumberedBoat(
                number: trip.id,
                color: _trip.isUploaded ? OlracColours.olspsDarkBlue : OlracColours.olspsBlue,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TimeSpace(label: 'Start', location: trip.startLocation, dateTime: trip.startedAt),
                    const SizedBox(height: 5),
                    if (trip.endedAt != null)
                      TimeSpace(label: 'End', location: trip.endLocation, dateTime: trip.endedAt),
                  ],
                ),
              )
            ],
          ),
        ),
        if (!_trip.isUploaded)
          Row(
            children: <Widget>[Expanded(child: editTripButton)],
          ),
      ],
    );
  }

  Widget get editTripButton => Builder(builder: (BuildContext context) {
        return StripButton(
          labelText: 'Edit',
          color: OlracColours.olspsBlue,
          onPressed: _onPressEditTrip,
          icon: Icon(
            Icons.edit,
            color: Colors.white,
          ),
        );
      });

  Widget get noHauls => Container(
        alignment: Alignment.center,
        child: const Text('No hauls on this trip', style: TextStyle(fontSize: 20)),
      );

  Widget uploadButton(Trip trip) {
    final label = trip.isUploaded ? 'Uploaded' : 'Upload Trip';
    final Function onPress = trip.isUploaded ? null : () async => await onPressUpload(trip);
    return StripButton(
      labelText: label,
      disabled: trip.isUploaded,
      color: OlracColours.olspsBlue,
      onPressed: onPress,
      icon: Icon(
        trip.isUploaded ? Icons.check_circle_outline : Icons.cloud_upload,
        color: Colors.white,
      ),
    );
  }

  Future<bool> _confirmUseMobileData() async => await showDialog<bool>(
        context: context,
        builder: (_) => const ConfirmDialog(
            'Use mobile data?', 'Using mobile data is disabled in settings. Would you still like to upload?'),
      );

  /// Upload the trip to the DDM.
  Future<void> onPressUpload(Trip trip) async {
    final ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

    if(connectivityResult == ConnectivityResult.none) {
      showTextSnackBar(_scaffoldKey, 'No internet connection. Upload failed.');
      return;
    }

    if (connectivityResult == ConnectivityResult.mobile) {
      final bool confirmed = await _confirmUseMobileData();
      if (!confirmed) {
        return;
      }
    }

    print('Uploading trip');

    // You may not upload active trip
    assert(!isActiveTrip);

    if (_uploading) {
      print('Already uploading');
      return;
    }

    if (trip.isUploaded) {
      print('Trip was already uploaded');
      // Refresh so user can see
      setState(() {});
      return;
    }

    _scaffoldKey.currentState.showSnackBar(
      const SnackBar(content: Text('Uploading Trip...'), duration: Duration(minutes: 20)),
    );

    setState(() {
      _uploading = true;
    });

    String snackBarMessage;
    try {
      await TripUploadService.uploadTrip(trip);

      print('Trip uploaded');
      snackBarMessage = 'Trip upload complete.';
    } on DioError {
      snackBarMessage = 'C';
    } catch (e) {
      snackBarMessage = 'Trip upload failed. Something unexpected went wrong.';
      handleError(e,null);
      print('Error:');
      print(e.toString());
    }

    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackBarMessage)));

    setState(() {
      _uploading = false;
    });
  }

  Text get _title {
    String text;
    text = isActiveTrip ? 'Active Trip' : 'Completed Trip';

    if (_trip.isUploaded) {
      text += ' (Uploaded)';
    }
    return Text(text);
  }

  Widget _groupedHaulsList() {
    return GroupedHaulsList(
      isActiveTrip: isActiveTrip,
      hauls: _trip.hauls.reversed.toList(),
      onPressHaulItem: (int id, int index) async {
        await Navigator.pushNamed(context, '/haul', arguments: {'haulId': id, 'listIndex': index});
        setState(() {});
      },
    );
  }

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
          return const Scaffold();
        }

        _trip = snapshot.data['trip'];
        isActiveTrip = snapshot.data['isActiveTrip'];

        final mainButton = isActiveTrip ? Container() : uploadButton(_trip);
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: _title),
          body: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildTripInfo(_trip),
                Expanded(
                  child: _trip.hauls.isNotEmpty ? _groupedHaulsList() : noHauls,
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
