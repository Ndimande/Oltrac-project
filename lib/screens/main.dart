import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
import 'package:oltrace/data/fishing_methods.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/messages.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/models/fishing_method_type.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/location.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:oltrace/providers/user_prefs.dart';
import 'package:oltrace/repositories/haul.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/screens/edit_trip.dart';
import 'package:oltrace/screens/fishing_method.dart';
import 'package:oltrace/screens/main/drawer.dart';
import 'package:oltrace/screens/main/haul_section.dart';
import 'package:oltrace/screens/main/no_active_trip.dart';
import 'package:oltrace/screens/main/static_haul_details_dialog.dart';
import 'package:oltrace/screens/main/trip_section.dart';
import 'package:oltrace/screens/master_container/master_containers.dart';
import 'package:oltrace/services/trip_upload.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _tripRepo = TripRepository();
final _haulRepo = HaulRepository();
final _locationProvider = LocationProvider();

Future<Map> _load() async {
  final Haul activeHaul = await _haulRepo.getActiveHaul();
  final Trip activeTrip = await _tripRepo.getActive();

  List<Product> tripProducts = [];
  if (activeTrip != null) {
    tripProducts = await ProductRepository().forTrip(activeTrip.id);
  }
  final List<Trip> completedTrips = await _tripRepo.getCompleted();

  return {
    'activeTrip': activeTrip,
    'activeHaul': activeHaul,
    'completedTrips': completedTrips,
    'showMCButton': tripProducts.isNotEmpty,
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

  /// Is the screen busy?
  bool busy = false;

  bool showMCButton;

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
    return StaticHaulDetailsDialog(onSuccesfulValidate: (Map<String, dynamic> formResult) {
      Navigator.pop(context, formResult);
    });
  }

  /// When the "Start Operation" bottom button is pressed.
  Future<void> _onPressStartFishing() async {
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
  Future<void> _onPressEndFishing() async {
    final bool confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          WestlakeConfirmDialog(Messages.endHaulTitle(activeHaul), Messages.endHaulDialogContent(activeHaul)),
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
      await _onPressEndFishing();
    else
      await _onPressStartFishing();
  }

  Future<void> _onPressFishingMethodStripButton() async {
    final FishingMethod method = await _selectCurrentFishingMethod();
    if (method != null) {
      widget.sharedPrefs.setString('fishingMethod', method.abbreviation);
    }
  }

  Future<Location> _determineLocation() async {
    Location location;

    // Show Snackbar and keep open
    showTextSnackBar(_scaffoldKey, Messages.WAITING_FOR_GPS, duration: const Duration(hours: 99));

    try {
      location = await _locationProvider.location;

      // Hide the waiting snackbar
      _scaffoldKey.currentState.hideCurrentSnackBar();

      if (location == null) {
        if (!await _locationProvider.locationServiceEnabled) {
          showTextSnackBar(_scaffoldKey, 'Location service is not enabled');
        } else {
          showTextSnackBar(_scaffoldKey, Messages.LOCATION_NOT_AVAILABLE);
        }
      }
    } catch (e) {
      // Ensure previous snackbar closed because the error could happen any time
      _scaffoldKey.currentState.hideCurrentSnackBar();
      showTextSnackBar(_scaffoldKey, Messages.LOCATION_NOT_AVAILABLE);
      rethrow;
    }
    return location;
  }

  Future<void> _onPressStartTripButton() async {
    if (busy) {
      return;
    }

    setState(() {
      busy = true;
    });

    final Location location = await _determineLocation();

    if (location == null) {
      return;
    }

    final trip = Trip(startedAt: DateTime.now(), startLocation: location);
    await _tripRepo.store(trip);

    setState(() {
      busy = false;
    });
  }

  Future<void> _onPressEndTrip() async {
    if (busy) {
      return;
    }

    setState(() {
      busy = true;
    });

    assert(activeHaul == null);

    final bool confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const WestlakeConfirmDialog('End Trip', Messages.TRIP_CONFIRM_END),
    );

    if (confirmed == true) {
      final Location location = await _locationProvider.location;

      if (location == null) {
        showTextSnackBar(_scaffoldKey, 'Please enable location and try again.');
        return;
      }

      final Trip endedTrip = activeTrip.copyWith(endedAt: DateTime.now(), endLocation: location);
      await _tripRepo.store(endedTrip);

      if (widget.userPrefs.uploadAutomatically) {
        try {
          final connectivity = await Connectivity().checkConnectivity();
          if (connectivity != ConnectivityResult.none) {
            if (connectivity == ConnectivityResult.mobile) {
              if (widget.userPrefs.mobileData) {
                TripUploadService.uploadTrip(endedTrip);
              } else {
                print('Allow mobile disabled. Trip must be uploaded later');
              }
            } else {
              TripUploadService.uploadTrip(endedTrip);
            }
          } else {
            print('No internet connection. Trip must be uploaded later');
          }
        } on DioError catch (e) {
          print('Upload Failed');
          print(e.error);
        }
      }

      setState(() {});
    }
    setState(() {
      busy = false;
    });
  }

  Future<void> _onPressEditTrip() async {
    final EditTripResult result = await Navigator.push(
      _scaffoldKey.currentContext,
      MaterialPageRoute(builder: (_) => EditTripScreen(activeTrip)),
    );

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
      actions: <Widget>[_appBarDate],
      title: _appBarTitle(),
    );
  }

  Widget get _appBarDate {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      alignment: Alignment.center,
      child: Text(friendlyDate(DateTime.now())),
    );
  }

  Widget _fishingMethodStripButton(FishingMethod fishingMethod) {
    final String title = fishingMethod == null ? 'Fishing Method' : 'New Gear';
    return Expanded(
      child: StripButton(
        labelText: title,
        icon: const Icon(Icons.apps, color: Colors.white),
        color: OlracColours.fauxPasBlue,
        onPressed: () async => await _onPressFishingMethodStripButton(),
      ),
    );
  }

  Widget _haulStripButton(FishingMethod fishingMethod) {
    String labelText;
    if (fishingMethod.type == FishingMethodType.Dynamic) {
      labelText = activeHaul == null ? 'Start Fishing' : 'End Fishing';
    } else {
      labelText = activeHaul == null ? 'New Haul' : 'Haul ${fishingMethod.name}';
    }

    return Expanded(
      child: StripButton(
        labelText: labelText,
        icon: Icon(
          activeHaul != null ? Icons.stop : Icons.play_arrow,
          color: Colors.white,
        ),
        color: activeHaul != null ? OlracColours.ninetiesRed : OlracColours.ninetiesGreen,
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
            },
          );
        }

        return Column(
          children: <Widget>[
            TripSection(
              trip: activeTrip,
              hasActiveHaul: activeHaul != null,
              onPressEndTrip: () async => await _onPressEndTrip(),
              onPressEditTrip: _onPressEditTrip,
              showMCButton: showMCButton,
              onPressMasterContainerButton: () async => await _onPressMasterContainerButton(),
            ),
            Expanded(
              child: HaulSection(
                hauls: activeTrip.hauls,
                onPressHaulItem: (int id, int index) async {
                  await Navigator.pushNamed(context, '/haul', arguments: {'haulId': id, 'listIndex': index});
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
          if (!snapshot.hasData) return const Scaffold();

          activeTrip = snapshot.data['activeTrip'] as Trip;
          activeHaul = snapshot.data['activeHaul'] as Haul;
          completedTrips = snapshot.data['completedTrips'] as List<Trip>;
          showMCButton = snapshot.data['showMCButton'] as bool;

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
