import 'package:geolocator/geolocator.dart';
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

// The store-class
abstract class _AppStore with Store {
  final tripRepo = TripRepository();
  final haulRepo = HaulRepository();
  final tagRepo = TagRepository();
  final jsonRepo = JsonRepository();
  final Geolocator geoLocator = Geolocator();

  @observable
  Map<String, dynamic> settings;

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
  @computed
  Haul get activeHaul {
    if (activeTrip == null) {
      return null;
    }
    return activeTrip.hauls.firstWhere((Haul haul) => haul.endedAt == null, orElse: () => null);
  }

  /// The profile of the user.
  /// If null, the user will be prompted
  /// to complete the profile form.
  @observable
  Profile profile;

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

  @action
  Future<Haul> startHaul(FishingMethod method) async {
    if (activeTrip == null) {
      throw Exception('No active trip');
    }

    Position position = await geoLocator.getLastKnownPosition();
    if (position == null) {
      // This can take a few seconds
      position = await geoLocator.getCurrentPosition();
    }

    final haul = Haul(
      fishingMethod: method,
      startedAt: DateTime.now(),
      tripId: activeTrip.id,
      startPosition: position,
    );

    final haulId = await haulRepo.store(haul);
    final newHaul = haul.copyWith(id: haulId);

    final updatedTrip = activeTrip.copyWith(hauls: [...activeTrip.hauls, newHaul]);

    activeTrip = updatedTrip;

    return haul;
  }

  @action
  Future<Haul> endHaul() async {
    // Make sure we don't get a funny state
    if (activeHaul == null) {
      throw Exception("No active haul");
    }

    Position position = await geoLocator.getLastKnownPosition();

    if (position == null) {
      // This can take a few seconds
      position = await geoLocator.getCurrentPosition();
    }

    final endedHaul = activeHaul.copyWith(
      endedAt: DateTime.now(),
      tripId: activeTrip.id,
      endPosition: position,
    );

    await haulRepo.store(endedHaul);

    final updatedHauls = activeTrip.hauls.map((Haul haul) {
      if (haul.id == endedHaul.id) {
        return endedHaul;
      }
      return haul;
    }).toList();

    // update state
    activeTrip = activeTrip.copyWith(hauls: updatedHauls);
    print(activeTrip);
    return endedHaul;
  }

  @action
  Future<Trip> startTrip() async {
    Position position = await geoLocator.getLastKnownPosition();

    if (position == null) {
      // This can take a few seconds
      position = await geoLocator.getCurrentPosition();
    }

    final trip = Trip(startedAt: DateTime.now(), startPosition: position);

    final int tripId = await tripRepo.store(trip);

    activeTrip = trip.copyWith(id: tripId);

    return activeTrip;
  }

  @action
  Future<Trip> endTrip() async {
    if (activeTrip == null) {
      throw Exception("No active trip.");
    }

    Position position = await geoLocator.getLastKnownPosition();

    if (position == null) {
      // This can take a few seconds
      position = await geoLocator.getCurrentPosition();
    }

    final endedTrip = activeTrip.copyWith(endedAt: DateTime.now(), endPosition: position);

    await tripRepo.store(endedTrip);

    // If the trip is being ended, Haul must be ended
    if (activeHaul != null) {
      await endHaul();
    }

    completedTrips = [...completedTrips, endedTrip];

    activeTrip = null;
    return endedTrip;
  }

  @action
  Future<void> saveProfile(Profile updatedProfile) async {
    await jsonRepo.set('profile', updatedProfile);
    profile = updatedProfile;
  }

  @computed
  bool get hasActiveHaul => activeHaul != null;

  @computed
  bool get profileConfigured => profile != null;

  @computed
  bool get hasActiveOrCompleteTrip {
    return activeTrip != null || completedTrips.length > 0;
  }

  @computed
  bool get activeTripHasActiveOrCompleteHaul {
    if (activeTrip == null) {
      throw Exception('No active trip');
    }
    return activeTrip.hauls.length > 0 || activeHaul != null;
  }

  @computed
  bool get hasActiveTrip => activeTrip != null;

  @computed
  int get activeTripTagsCount {
    if (activeTrip == null) {
      throw new Exception('No active trip');
    }
    if (activeTrip.hauls.length == 0 && activeHaul == null) {
      return 0;
    }
    return activeTrip.hauls.fold(0, (int total, Haul elem) => total + elem.tags.length);
  }

  PackageInfo packageInfo;
}
