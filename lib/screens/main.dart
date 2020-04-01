import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/data/fishing_methods.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/messages.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/models/fishing_method_type.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/location.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:oltrace/repositories/haul.dart';
import 'package:oltrace/repositories/landing.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/screens/edit_trip.dart';
import 'package:oltrace/screens/fishing_method.dart';
import 'package:oltrace/screens/main/drawer.dart';
import 'package:oltrace/screens/main/haul_section.dart';
import 'package:oltrace/screens/main/no_active_trip.dart';
import 'package:oltrace/screens/main/trip_section.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/strip_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final SharedPreferences sharedPrefs = SharedPreferencesProvider().sharedPreferences;

  MainScreen();

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Trip activeTrip;
  Haul activeHaul;
  List<Trip> completedTrips;

  FishingMethod get _fishingMethod {
    final String fmCode = widget.sharedPrefs.getString('fishingMethod').toString();
    return fishingMethods.singleWhere(
        (FishingMethod element) => element.abbreviation.toLowerCase() == fmCode.toLowerCase(),
        orElse: () => null);
  }

  Future<FishingMethod> _selectFishingMethod() async {
    final fm = await Navigator.push<FishingMethod>(
      context,
      MaterialPageRoute(builder: (context) => FishingMethodScreen()),
    );
    setState(() {});
    return fm;
  }

  Picker _soakTimePicker() {
    return Picker(
        title: Text('Soak Time'),
        onConfirm: _onConfirmSoakTime,
        adapter: PickerDataAdapter<String>(isArray: true, pickerdata: <List<String>>[
          List.generate(AppConfig.MAX_SOAK_HOURS_SELECTABLE, (int index) => '$index hours'),
          List.generate(12, (int index) => '${index * 5} minutes'),
        ]));
  }

  Future<void> _onConfirmSoakTime(Picker picker, List<int> indices) async {
    final int hours = indices[0];
    final int minutes = indices[1] * 5;
    print([hours, minutes]);
    final Duration soakTime = Duration(hours: hours, minutes: minutes);
    await _startOperation(soakTime: soakTime);
  }

  Future<void> _startOperation({Duration soakTime}) async {
    try {
      final Location location = await _locationProvider.location;

      final haul = Haul(
        fishingMethod: _fishingMethod,
        startedAt: DateTime.now(),
        tripId: activeTrip.id,
        startLocation: location,
        soakTime: soakTime,
      );

      await _haulRepo.store(haul);
      setState(() {});
    } catch (e) {
      showTextSnackBar(_scaffoldKey, 'Could not start fishing/hauling. ${Messages.LOCATION_NOT_AVAILABLE}');
      print(e);
    }
  }

  Future<void> _onPressStartStripButton() async {
    if (_fishingMethod.type == FishingMethodType.Static) {
      _soakTimePicker().showModal(context);
    } else {
      await _startOperation();
    }
  }

  Future<void> _onPressEndHaul() async {
    bool confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmDialog(Messages.endHaulTitle(activeHaul), Messages.endHaulDialogContent(activeHaul)),
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
        showTextSnackBar(_scaffoldKey, 'There was an error. Could not end hauling/fishing');
        rethrow;
      }
    }
  }

  Future<void> _onPressHaulStripButton() async {
    if (activeHaul != null)
      await _onPressEndHaul();
    else
      await _onPressStartStripButton();
  }

  Future<void> _onPressFishingMethodStripButton() async {
    final FishingMethod method = await _selectFishingMethod();
    if (method != null) {
      widget.sharedPrefs.setString('fishingMethod', method.abbreviation);
      setState(() {});
    }
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
      builder: (_) => ConfirmDialog('Cancel Trip', Messages.TRIP_CONFIRM_CANCEL),
    );
    if (confirmed == true) {
      await _tripRepo.delete(activeTrip.id);
      setState(() {});
    }
  }

  Future<void> _onPressEndTrip(bool hasActiveHaul) async {
    if (hasActiveHaul) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('You must first end hauling/fishing')));
      return;
    }

    bool confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmDialog('End Trip', Messages.TRIP_CONFIRM_END),
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

  Text _appBarTitle() {
    final String verb =
        activeHaul != null && activeHaul.fishingMethod.type == FishingMethodType.Dynamic ? 'Fishing...' : 'Hauling...';
    final String title = activeTrip != null ? activeHaul != null ? verb : 'Active Trip' : 'Completed Trips';
    return Text(title);
  }

  Widget _appBar() {
    return AppBar(
      actions: <Widget>[_appBarDate],
      title: _appBarTitle(),
    );
  }

  Widget get _appBarDate {
    return Container(
      margin: EdgeInsets.only(right: 10),
      alignment: Alignment.center,
      child: Text(friendlyDate(DateTime.now())),
    );
  }

  Widget _fishingMethodStripButton(FishingMethod fishingMethod) {
    final String title = fishingMethod == null ? 'Fishing Method' : fishingMethod.name;
    return Expanded(
      child: StripButton(
        labelText: title,
        icon: Icon(
          Icons.cached,
          color: Colors.white,
        ),
        color: olracBlue,
        onPressed: () async => await _onPressFishingMethodStripButton(),
      ),
    );
  }

  Widget _haulStripButton(FishingMethod fishingMethod) {
    final String actionType = (fishingMethod.type == FishingMethodType.Dynamic ? 'Fishing' : 'Hauling');
    final String actionVerb = activeHaul != null ? 'End' : 'Start';
    final String labelText = "$actionVerb $actionType";
    return Expanded(
      child: StripButton(
        labelText: labelText,
        icon: Icon(
          activeHaul != null ? Icons.stop : Icons.play_arrow,
          color: Colors.white,
        ),
        color: activeHaul != null ? Colors.red : Colors.green,
        onPressed: () async => await _onPressHaulStripButton(),
      ),
    );
  }

  Widget _bottomButtons() {
    final FishingMethod fishingMethod = _fishingMethod;

    return Row(
      children: <Widget>[
        if (fishingMethod != null) _haulStripButton(fishingMethod),
        if (activeHaul == null) _fishingMethodStripButton(fishingMethod)
      ],
    );
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
                    _bottomButtons(),
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
