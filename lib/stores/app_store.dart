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

  @action
  void startTrip(Trip trip) => _trip = trip;

  @action
  void endTrip() {
    _completedTrips.add(_trip);
    _trip = null;
  }

  @computed
  bool get tripHasStarted => _trip != null;

  /// [HAUL]
  @observable
  Haul _haul;

  Haul get currentHaul => _haul;

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
