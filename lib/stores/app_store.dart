import 'package:mobx/mobx.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/vessel.dart';

// Include generated file
part 'app_store.g.dart';

// This is the class used by rest of your codebase
class AppStore = _AppStore with _$AppStore;

enum NavIndex { trip, haul, tag, tagPrimary, tagSecondary, configureVessel }
enum ContextMenuIndex { about, endTrip }

// The store-class
abstract class _AppStore with Store {
  final title = 'OlTrace';

  /// [NAVIGATION]
  @observable
  NavIndex currentNavIndex = NavIndex.trip;

  @action
  void changeMainView(NavIndex index) {
    currentNavIndex = index;
  }

  /// [TRIP]

  /// The trip that is currently running.
  @observable
  Trip _activeTrip;
  Trip get activeTrip => _activeTrip;

  /// Trips that have been completed / ended.
  @observable
  List<Trip> _completedTrips = [];
  List<Trip> get completedTrips => _completedTrips;

  /// Begin a new trip
  /// todo We shouldn't pass in a trip, one should be created here.
  @action
  void startTrip(Trip trip) => _activeTrip = trip;

  @action
  void endTrip() {
    List _updatedTrips = _completedTrips;
    _updatedTrips.add(_activeTrip);
    _completedTrips = _updatedTrips;
    _activeTrip = null;
  }

  @computed
  bool get tripHasStarted => _activeTrip != null;

  /// [HAUL]

  /// The current haul.
  @observable
  Haul _activeHaul;

  /// Public getter for the current haul.
  Haul get activeHaul => _activeHaul;

  /// Hauls that have been ended.
  @observable
  List<Haul> _completedHauls = [];

  List<Haul> get completedHauls => _completedHauls;

  @action
  void startHaul(Haul haul) => _activeHaul = haul;

  @action
  void endHaul() {
    List _updatedHauls = _completedHauls;
    _updatedHauls.add(_activeHaul);
    _completedHauls = _updatedHauls;
    _activeHaul = null;
  }

  @computed
  bool get haulHasStarted => _activeHaul != null;

  /// [VESSEL]
  @observable
  Vessel _vessel;

  Vessel get vessel => _vessel;

  @action
  void setVessel(Vessel vessel) => _vessel = vessel;

  @computed
  bool get vesselIsConfigured => _vessel != null;
}
