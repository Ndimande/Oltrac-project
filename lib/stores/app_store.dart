import 'package:mobx/mobx.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/models/tag.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/repositories/haul.dart';
import 'package:oltrace/repositories/json.dart';
import 'package:oltrace/repositories/tag.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:package_info/package_info.dart';

// Include generated file
part 'app_store.g.dart';

// This is the class used by rest of your codebase
class AppStore = _AppStore with _$AppStore;

enum NavIndex { trip, haul, tag, tagPrimary, tagSecondary }
enum ContextMenuIndex { about, endTrip }

// The store-class
abstract class _AppStore with Store {
  final tripRepo = TripRepository();
  final haulRepo = HaulRepository();
  final tagRepo = TagRepository();
  final jsonRepo = JsonRepository();

  /// The [MainScreen] view to be shown
  @observable
  NavIndex mainNavIndex = NavIndex.trip;

  /// Trips that have been completed / ended.
  @observable
  List<Trip> completedTrips = [];

  /// The active [Trip].
  /// null if no trip is currently active.
  ///
  /// Also holds the hauls of the current
  /// trip except the active [Haul].
  @observable
  Trip activeTrip;

  /// The active [Haul]
  /// null if no haul is currently active.
  @observable
  Haul activeHaul;

  /// The profile of the user.
  /// If null, the user will be prompted
  /// to complete the profile form.
  @observable
  Profile profile;

  @action
  void changeMainView(NavIndex index) {
    mainNavIndex = index;
  }

  /// [TAG]
  @action
  Future<Tag> saveTag(Tag tag) async {
    final tagId = await tagRepo.store(tag);
    tag = tag.copyWith(id: tagId);

    // update trip
    final List<Haul> updatedHauls = activeTrip.hauls.map((Haul haul) {
      if (haul.id == tag.haulId) {
        return haul.copyWith(tags: [...haul.tags, tag]);
      }
      return haul;
    }).toList();

    final Trip updatedTrip = activeTrip.copyWith(hauls: updatedHauls);

    activeTrip = updatedTrip;

    return tag;
  }

  /// [HAUL]
  @action
  Future<Haul> startHaul(FishingMethod method) async {
    if (activeTrip == null) {
      throw Exception('No active trip');
    }
    final haul = Haul(
      fishingMethod: method,
      startedAt: DateTime.now(),
      tripId: activeTrip.id,
    );

    final haulId = await haulRepo.store(haul);
    activeHaul = haul.copyWith(id: haulId);
    return haul;
  }

  @action
  Future<Haul> endHaul() async {
    // Make sure we don't get a funny state
    if (activeHaul == null) {
      throw Exception("No active haul");
    }

    final endedHaul =
        activeHaul.copyWith(endedAt: DateTime.now(), tripId: activeTrip.id);
    await haulRepo.store(endedHaul);

    // Update the current trip's hauls
    activeTrip = activeTrip.copyWith(hauls: [...activeTrip.hauls, endedHaul]);

    // There is no haul active now
    activeHaul = null;

    return endedHaul;
  }

  @computed
  bool get haulHasStarted => activeHaul != null;

  @action
  Future<void> saveProfile(Profile updatedProfile) async {
    await jsonRepo.set('profile', updatedProfile);
    profile = updatedProfile;
  }

  @computed
  bool get profileConfigured => profile != null;

  /// [TRIP]
  @computed
  bool get hasActiveOrCompleteTrip {
    return activeTrip != null || completedTrips.length > 0;
  }

  bool get activeTripHasActiveOrCompleteHaul {
    if (activeTrip == null) {
      throw Exception('No active trip');
    }
    return activeTrip.hauls.length > 0 || activeHaul != null;
  }

  @computed
  bool get tripHasStarted => activeTrip != null;

  @computed
  int get activeTripTagsCount {
    if (activeTrip == null) {
      throw new Exception('No active trip');
    }
    if (activeTrip.hauls.length == 0 && activeHaul == null) {
      return 0;
    }
    return activeTrip.hauls
        .fold(0, (int total, Haul elem) => total + elem.tags.length);
  }

  @action
  Future<Trip> startTrip() async {
    Trip trip = Trip(startedAt: DateTime.now());
    int tripId = await tripRepo.store(trip);
    activeTrip = trip.copyWith(id: tripId);
    return activeTrip;
  }

  @action
  Future<Trip> endTrip() async {
    if (activeTrip == null) {
      throw Exception("No active trip.");
    }

    final endedTrip = activeTrip.copyWith(endedAt: DateTime.now());

    await tripRepo.store(endedTrip);

    // If the trip is being ended, Haul must be ended
    if (activeHaul != null) {
      await endHaul();
    }

    completedTrips = [...completedTrips, endedTrip];

    activeTrip = null;
    return endedTrip;
  }

  PackageInfo packageInfo;
}
