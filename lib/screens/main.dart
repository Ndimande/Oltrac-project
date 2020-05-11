import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
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
import 'package:oltrace/providers/user_prefs.dart';
import 'package:oltrace/repositories/haul.dart';
import 'package:oltrace/repositories/landing.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/screens/edit_trip.dart';
import 'package:oltrace/screens/fishing_method.dart';
import 'package:oltrace/screens/main/static_haul_details_alert_dialog.dart';
import 'package:oltrace/screens/main/drawer.dart';
import 'package:oltrace/screens/main/haul_section.dart';
import 'package:oltrace/screens/main/no_active_trip.dart';
import 'package:oltrace/screens/main/trip_section.dart';
import 'package:oltrace/screens/master_containers.dart';
import 'package:oltrace/services/trip_upload.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/strip_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _tripRepo = TripRepository();
final _haulRepo = HaulRepository();
final _landingRepo = LandingRepository();
final _productRepo = ProductRepository();
final _locationProvider = LocationProvider();

Future<Trip> _addNestedData(Trip trip) async {
  List<Haul> activeTripHauls = await _haulRepo.forTripId(trip.id);
  final List<Haul> hauls = [];
  for (Haul haul in activeTripHauls) {
    final List<Landing> landings = await _landingRepo.forHaul(haul);
    final List<Landing> landingWithProducts = [];
    for (Landing landing in landings) {
      final List<Product> products = await _productRepo.forLanding(landing.id);
      landingWithProducts.add(landing.copyWith(products: products));
    }
    hauls.add(haul.copyWith(products: landingWithProducts));
  }
  return trip.copyWith(hauls: hauls);
}

Future<Map> _load() async {
  final Haul activeHaul = await _haulRepo.getActiveHaul();
  Trip activeTrip = await _tripRepo.getActive();
  if (activeTrip != null) {
    activeTrip = await _addNestedData(activeTrip);
  }

  final List<Trip> completedTrips = await _tripRepo.getCompleted();
  final List<Trip> tripsWithHauls = [];
  for (Trip trip in completedTrips) {
    final Trip withNested = await _addNestedData(trip);
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
  final userPrefs = UserPrefsProvider().userPrefs;

  MainScreen();

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /// The [Trip] that is currently ongoing.
  /// null when no trip is active.
  Trip activeTrip;

  /// The [Haul] that is in progress.
  /// null when no haul is active.
  Haul activeHaul;

  /// List of [Trip]s that have ended.
  List<Trip> completedTrips;

  /// Get the currently selected [FishingMethod].
  FishingMethod get _currentFishingMethod {
    final String fmCode = widget.sharedPrefs.getString('fishingMethod').toString();
    return fishingMethods.singleWhere(
      (FishingMethod fm) => fm.abbreviation.toLowerCase() == fmCode.toLowerCase(),
      orElse: () => null,
    );
  }

  /// Select or change the current [FishingMethod]
  Future<FishingMethod> _selectCurrentFishingMethod() async {
    final fm = await Navigator.push<FishingMethod>(
      context,
      MaterialPageRoute(builder: (context) => FishingMethodScreen()),
    );
    setState(() {});
    return fm;
  }

  /// Being a new [Haul]
  Future<void> _startOperation({Duration soakTime, int trapsOrHooks}) async {
    try {
      final Location location = await _locationProvider.location;

      final haul = Haul(
        fishingMethod: _currentFishingMethod,
        startedAt: DateTime.now(),
        tripId: activeTrip.id,
        startLocation: location,
        soakTime: soakTime,
        hooksOrTraps: trapsOrHooks,
      );

      await _haulRepo.store(haul);
      setState(() {});
    } catch (e) {
      showTextSnackBar(_scaffoldKey, 'Could not start fishing/hauling. ${Messages.LOCATION_NOT_AVAILABLE}');
      print(e);
    }
  }

  /// Dialog to select soak time.
  Widget _soakTimeDialog() {
    return StaticHaulDetailsAlertDialog(onSuccesfulValidate: (Map<String, dynamic> formResult) {
      Navigator.pop(context, formResult);
    });
  }

  /// When the "Start Operation" bottom button is pressed.
  Future<void> _onPressStartStripButton() async {
    if (_currentFishingMethod.type == FishingMethodType.Static) {
      final Map<String, dynamic> formResult = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return _soakTimeDialog();
        },
      );

      if (formResult != null) {
        final Duration soakTime = formResult['soakDuration'] as Duration;
        final int numberOfTrapsOrHooks = formResult['numberOfTrapsOrHooks'] as int;
        _startOperation(soakTime: soakTime, trapsOrHooks: numberOfTrapsOrHooks);
      }
    } else {
      await _startOperation();
    }
  }

  /// When the "End Haul" bottom button is pressed.
  Future<void> _onPressEndStripButton() async {
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

  /// Either the start or end haul button is pressed.
  Future<void> _onPressHaulStripButton() async {
    if (activeHaul != null)
      await _onPressEndStripButton();
    else
      await _onPressStartStripButton();
  }

  Future<void> _onPressFishingMethodStripButton() async {
    final FishingMethod method = await _selectCurrentFishingMethod();
    if (method != null) {
      widget.sharedPrefs.setString('fishingMethod', method.abbreviation);
      setState(() {});
    }
  }

  Future<void> _onPressStartTripButton() async {
    showTextSnackBar(_scaffoldKey, Messages.WAITING_FOR_GPS);

    try {
      final Location location = await _locationProvider.location;
      print(location);
      if (location == null) {
        if (!await _locationProvider.locationServiceEnabled) {
          showTextSnackBar(_scaffoldKey, 'Location service is not enabled');
        }
      }
      _scaffoldKey.currentState.hideCurrentSnackBar();
      final trip = Trip(startedAt: DateTime.now(), startLocation: location);
      final int id = await _tripRepo.store(trip);
      setState(() {});
      showTextSnackBar(_scaffoldKey, 'Trip $id started');
    } catch (e) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      showTextSnackBar(_scaffoldKey, Messages.LOCATION_NOT_AVAILABLE);
      rethrow;
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

      if (widget.userPrefs.uploadAutomatically) {
        await TripUploadService.uploadTrip(endedTrip);
      }
      showTextSnackBar(_scaffoldKey, 'Trip ${endedTrip.id} ended');

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

  Future<void> _onPressMasterContainerButton() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MasterContainersScreen(activeTrip.id)),
    );
  }

  Text _appBarTitle() {
    final String verb =
        activeHaul != null && activeHaul.fishingMethod.type == FishingMethodType.Dynamic ? 'Fishing...' : 'Hauling...';
    final String title = activeTrip != null ? activeHaul != null ? verb : 'Active Trip' : 'Completed Trips';
    return Text(title);
  }

  Widget _appBar() {
    return AppBar(
      actions: <Widget>[
        _appBarDate,
        if (activeTrip != null && activeTrip.hauls.isNotEmpty) _masterContainerButton(),
      ],
      title: _appBarTitle(),
    );
  }

  Widget _masterContainerButton() {
    return IconButton(
      icon: Icon(Icons.inbox),
      onPressed: _onPressMasterContainerButton,
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
    final String title = fishingMethod == null ? 'Fishing Method' : 'Change Gear';
    return Expanded(
      child: StripButton(
        labelText: title,
        icon: Icon(
          Icons.apps,
          color: Colors.white,
        ),
        color: OlracColours.olspsBlue,
        onPressed: () async => await _onPressFishingMethodStripButton(),
      ),
    );
  }

  Widget _haulStripButton(FishingMethod fishingMethod) {
    String labelText;
    if (fishingMethod.type == FishingMethodType.Dynamic) {
      labelText = activeHaul == null ? 'Start Fishing' : 'End Fishing';
    } else {
      labelText = 'Haul ${fishingMethod.name}';
    }

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
    final FishingMethod fishingMethod = _currentFishingMethod;

    return Row(
      children: <Widget>[
        if (fishingMethod != null) _haulStripButton(fishingMethod),
        if (activeHaul == null) _fishingMethodStripButton(fishingMethod)
      ],
    );
  }

  Widget _body() {
    return Builder(
      builder: (_) {
        if (activeTrip == null) {
          return NoActiveTrip(
            completedTrips: completedTrips,
            onPressStartTrip: () async => await _onPressStartTripButton(),
            onPressCompletedTrip: (Trip trip) async {
              await Navigator.pushNamed(context, '/trip', arguments: trip);
              setState(() {});
            },
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
            body: _body(),
          );
        },
      ),
    );
  }
}
