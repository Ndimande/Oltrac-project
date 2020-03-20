import 'package:flutter/material.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/messages.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/location.dart';
import 'package:oltrace/repositories/haul.dart';
import 'package:oltrace/repositories/landing.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/screens/edit_trip.dart';
import 'package:oltrace/widgets/screens/fishing_method.dart';
import 'package:oltrace/widgets/screens/main/drawer.dart';
import 'package:oltrace/widgets/screens/main/haul_section.dart';
import 'package:oltrace/widgets/screens/main/no_active_trip.dart';
import 'package:oltrace/widgets/screens/main/trip_section.dart';
import 'package:oltrace/widgets/strip_button.dart';

final _tripRepo = TripRepository();
final _haulRepo = HaulRepository();
final _landingRepo = LandingRepository();
final _productRepo = ProductRepository();
final _locationProvider = LocationProvider();

Future<Trip> _getWithNested(Trip trip) async {
  List<Haul> activeTripHauls = await _haulRepo.forTripId(trip.id);
  final List<Haul> hauls = [];
  for (Haul haul in activeTripHauls) {
    final List<Landing> landings = await _landingRepo.forHaul(haul);
    final List<Landing> landingWithProducts = [];
    for (Landing landing in landings) {
      final List<Product> products = await _productRepo.forLanding(landing.id);
      landingWithProducts.add(landing.copyWith(products: products));
    }
    hauls.add(haul.copyWith(landings: landingWithProducts));
  }
  return trip.copyWith(hauls: hauls);
}

Future<Map> _load() async {
  final Haul activeHaul = await _haulRepo.getActiveHaul();
  Trip activeTrip = await _tripRepo.getActive();
  if (activeTrip != null) {
    activeTrip = await _getWithNested(activeTrip);
  }

  final List<Trip> completedTrips = await _tripRepo.getCompleted();
  final List<Trip> tripsWithHauls = [];
  for (Trip trip in completedTrips) {
    final Trip withNested = await _getWithNested(trip);
    tripsWithHauls.add(withNested);
  }

  return {
    'activeTrip': activeTrip,
    'activeHaul': activeHaul,
    'completedTrips': tripsWithHauls,
  };
}

class MainScreen extends StatefulWidget {
  MainScreen();

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Trip activeTrip;
  Haul activeHaul;
  List<Trip> completedTrips;

  Widget _appBar() {
    final title = activeTrip != null ? activeHaul != null ? 'Hauling...' : 'Active Trip' : 'Completed Trips';
    return AppBar(
      actions: <Widget>[_appBarDate],
      title: Text(title),
    );
  }

  Widget get _appBarDate {
    return Container(
      margin: EdgeInsets.only(right: 10),
      alignment: Alignment.center,
      child: Text(friendlyDate(DateTime.now())),
    );
  }

  Future<FishingMethod> _selectFishingMethod() async {
    final fm = await Navigator.push<FishingMethod>(
      context,
      MaterialPageRoute(builder: (context) => FishingMethodScreen()),
    );
    setState(() {});
    return fm;
  }

  Future<void> _onPressStartHaul() async {
    final FishingMethod method = await _selectFishingMethod();
    if (method != null) {
      try {
        final Location location = await _locationProvider.location;

        final haul = Haul(
          fishingMethod: method,
          startedAt: DateTime.now(),
          tripId: activeTrip.id,
          startLocation: location,
        );

        await _haulRepo.store(haul);
        setState(() {});
      } catch (e) {
        showTextSnackBar(_scaffoldKey, 'Could not start haul. ${Messages.LOCATION_NOT_AVAILABLE}');
        print(e);
      }
    }
  }

  Future<void> _onPressEndHaul() async {
    bool confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmDialog('End haul', Messages.CONFIRM_END_HAUL),
    );

    if (confirmed) {
      try {
        final Location location = await _locationProvider.location;

        final endedHaul = activeHaul.copyWith(
          endedAt: DateTime.now(),
          tripId: activeTrip.id,
          endLocation: location,
        );

        await _haulRepo.store(endedHaul);
        setState(() {});
      } catch (e) {
        print(e.toString());
        showTextSnackBar(_scaffoldKey, 'Could not end haul. ${Messages.LOCATION_NOT_AVAILABLE}');
        return;
      }
    }
  }

  Future<void> _onPressHaulActionButton() async {
    if (activeHaul != null)
      await _onPressEndHaul();
    else
      await _onPressStartHaul();
  }

  Future<void> _onPressStartTripButton() async {
    showTextSnackBar(_scaffoldKey, Messages.WAITING_FOR_GPS);

    try {
      final Location location = await _locationProvider.location;
      _scaffoldKey.currentState.hideCurrentSnackBar();
      final trip = Trip(startedAt: DateTime.now(), startLocation: location);
      final int id = await _tripRepo.store(trip);
      setState(() {});
      showTextSnackBar(_scaffoldKey, 'Trip $id has started');
    } catch (e) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      showTextSnackBar(_scaffoldKey, Messages.LOCATION_NOT_AVAILABLE);
    }
  }

  Future<void> _onPressCancelTrip(bool hasActiveHaul) async {
    if (hasActiveHaul) {
      showTextSnackBar(_scaffoldKey, 'You must first end the haul');
      return;
    }

    final bool confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog('Cancel Trip', Messages.CONFIRM_CANCEL_TRIP),
    );
    if (confirmed == true) {
      await _tripRepo.delete(activeTrip.id);
      setState(() {});
    }
  }

  Future<void> _onPressEndTrip(bool hasActiveHaul) async {
    if (hasActiveHaul) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('You must first end the haul')));
      return;
    }

    bool confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmDialog('End Trip', Messages.CONFIRM_END_TRIP),
    );
    if (confirmed == true) {
      final Location location = await _locationProvider.location;
      final Trip endedTrip = activeTrip.copyWith(endedAt: DateTime.now(), endLocation: location);
      await _tripRepo.store(endedTrip);
      showTextSnackBar(_scaffoldKey, 'Trip ${endedTrip.id} has been ended');
      setState(() {});
    }
  }

  Future<void> _onPressEditTrip() async {
    final EditTripResult result = await Navigator.push(
      _scaffoldKey.currentContext,
      MaterialPageRoute(builder: (_) => EditTripScreen(activeTrip)),
    );
    setState(() {});
    if (result == EditTripResult.TripCanceled)
      showTextSnackBar(_scaffoldKey, 'Trip canceled');
    else if (result == EditTripResult.Updated) showTextSnackBar(_scaffoldKey, 'Trip updated');
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: FutureBuilder(
        future: _load(),
        initialData: null,
        builder: (BuildContext buildContext, AsyncSnapshot snapshot) {
          if (snapshot.hasError) throw Exception(snapshot.error.toString());

          // Show blank screen until ready
          if (!snapshot.hasData) return Scaffold();

          activeTrip = snapshot.data['activeTrip'] as Trip;
          activeHaul = snapshot.data['activeHaul'] as Haul;
          completedTrips = snapshot.data['completedTrips'] as List<Trip>;

          final String labelText = activeHaul != null ? 'End Haul' : 'Start Haul';
          return Scaffold(
            key: _scaffoldKey,
            appBar: _appBar(),
            drawer: MainDrawer(),
            body: Builder(
              builder: (_) {
                if (activeTrip == null) {
                  return NoActiveTrip(
                    completedTrips: completedTrips,
                    onPressStartTrip: () async => await _onPressStartTripButton(),
                  );
                }

                return Column(
                  children: <Widget>[
                    TripSection(
                      trip: activeTrip,
                      hasActiveHaul: activeHaul != null,
                      onPressEndTrip: () async => await _onPressEndTrip(activeHaul != null),
                      onPressCancelTrip: () async => await _onPressCancelTrip(activeHaul != null),
                      onPressEditTrip: _onPressEditTrip,
                    ),
                    Expanded(
                      child: HaulSection(
                        hauls: activeTrip.hauls,
                        onPressHaulItem: (int id, int index) async {
                          await Navigator.pushNamed(context, '/haul', arguments: {'haulId': id, 'listIndex': index});
                          setState(() {});
                        },
                      ),
                    ),
                    StripButton(
                      centered: true,
                      labelText: labelText,
                      icon: Icon(
                        activeHaul != null ? Icons.stop : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      color: activeHaul != null ? Colors.red : Colors.green,
                      onPressed: () async => await _onPressHaulActionButton(),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
