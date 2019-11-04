import 'package:mobx/mobx.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/vessel.dart';

// Include generated file
part 'app_store.g.dart';

// This is the class used by rest of your codebase
class AppStore = _AppStore with _$AppStore;

enum MainViewIndex { home, haul, tag, configureVessel }
enum ContextMenuIndex { about, endTrip }

// The store-class
abstract class _AppStore with Store {
  final title = 'OlTrace';

  /// [NAVIGATION]
  @observable
  MainViewIndex currentMainViewIndex = MainViewIndex.home;

  @action
  void changeMainView(MainViewIndex index) {
    currentMainViewIndex = index;
  }

  /// [TRIP]
  @observable
  Trip _trip;

  @observable
  List<Trip> _completedTrips = [];

  Trip get currentTrip => _trip;

  List<Trip> get completedTrips => _completedTrips;

  @action
  void startTrip(Trip trip) => _trip = trip;

  @action
  void endTrip() {
    List _updatedTrips = _completedTrips;
    _updatedTrips.add(_trip);
    _completedTrips = _updatedTrips;
    print(_completedTrips);
    _trip = null;
  }

  @computed
  bool get tripHasStarted => _trip != null;

  /// [HAUL]

  @observable
  Haul _haul;

  @observable
  List<Haul> _completedHauls = [];

  Haul get currentHaul => _haul;

  @action
  void startHaul(Haul haul) => _haul = haul;

  @action
  void endHaul() {
    List _updatedHauls = _completedHauls;
    _updatedHauls.add(_haul);
    _haul = null;
  }

  @computed
  bool get haulHasStarted => _haul != null;

  /// [VESSEL]
  @observable
  Vessel _vessel;

  Vessel get vessel => _vessel;

  @action
  void setVessel(Vessel vessel) => _vessel = vessel;

  @computed
  bool get vesselIsConfigured => _vessel != null;
}
