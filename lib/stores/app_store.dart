import 'package:mobx/mobx.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/vessel.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Include generated file
part 'app_store.g.dart';

// This is the class used by rest of your codebase
class AppStore = _AppStore with _$AppStore;

enum NavIndex { trip, haul, tag, tagPrimary, tagSecondary, configureVessel }
enum ContextMenuIndex { about, endTrip }

// The store-class
abstract class _AppStore with Store {
  /// [NAVIGATION]
  @observable
  NavIndex mainNavIndex = NavIndex.trip;

  @action
  void changeMainView(NavIndex index) {
    mainNavIndex = index;
  }

  /// [TRIP]

  /// The trip that is currently running.
  /// null if no active trip.
  @observable
  Trip _activeTrip;

  Trip get activeTrip => _activeTrip;

  /// Trips that have been completed / ended.
  @observable
  List<Trip> _completedTrips = [];

  set completedTrips(trips) => _completedTrips = trips;

  List<Trip> get completedTrips => _completedTrips;

  /// Begin a new trip
  @action
  Trip startTrip() {
    Trip trip = Trip(startedAt: DateTime.now(), vessel: _vessel);
    _activeTrip = trip;
    print('Trip started');
    return _activeTrip;
  }

  @action
  Trip endTrip() {
    if (_activeTrip == null) {
      throw Exception("No active trip");
    }

    final endedTrip = _activeTrip.copyWith(endedAt: DateTime.now());

    // If the trip is being ended, Haul must be ended
    if (_activeHaul != null) {
      _endHaul();
    }

    _completedTrips = [...completedTrips, endedTrip];
    print('Trip ended');

    _activeTrip = null;
    return endedTrip;
  }

  @computed
  bool get tripHasStarted => _activeTrip != null;

  /// [HAUL]

  /// The current haul.
  @observable
  Haul _activeHaul;

  /// Public getter for the current haul.
  Haul get activeHaul => _activeHaul;

  @action
  void startHaul(FishingMethod method) {
    if (_activeTrip == null) {
      throw Exception('No active trip');
    }
    final haul = Haul(fishingMethod: method, startedAt: DateTime.now());
    _activeHaul = haul;
  }

  void _endHaul() {
    // Make sure we don't get a funny state
    if (_activeHaul == null) {
      throw Exception("No active haul");
    }

    // Update the current trip's hauls
    _activeTrip = _activeTrip.copyWith(hauls: [
      ..._activeTrip.hauls,
      _activeHaul.copyWith(endedAt: DateTime.now())
    ]);

    // There is no haul active now
    _activeHaul = null;
  }

  @action
  void endHaul() {
    _endHaul();
  }

  @computed
  bool get haulHasStarted => _activeHaul != null;

  /// [VESSEL]
  @observable
  Vessel _vessel;

  Vessel get vessel => _vessel;

  Future persistVessel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('country', _vessel.country.toJson());
  }

  @action
  void setVessel(Vessel vessel) {
    _vessel = vessel;
    pd({'vessel': _vessel});
  }

  @computed
  bool get vesselIsConfigured => _vessel != null;

  /// [TRIP]
  @computed
  bool get hasActiveOrCompleteTrip {
    return _activeTrip != null || _completedTrips.length > 0;
  }

  bool get activeTripHasActiveOrCompleteHaul {
    if (_activeTrip == null) {
      throw Exception('No active trip');
    }
    return _activeTrip.hauls.length > 0 || _activeHaul != null;
  }

  @computed
  int get activeTripTagsCount {
    if (_activeTrip == null) {
      throw new Exception('No active trip');
    }
    if (_activeTrip.hauls.length == 0 && _activeHaul == null) {
      return 0;
    }
    return _activeTrip.hauls.fold(0, (int total, Haul elem) {
      return total + elem.tags.length;
    });
  }
}
