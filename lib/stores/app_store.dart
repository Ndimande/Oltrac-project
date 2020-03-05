
import 'package:mobx/mobx.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/repositories/json.dart';
import 'package:package_info/package_info.dart';

part 'app_store.g.dart';

// This is the class used by rest of your codebase
class AppStore = _AppStore with _$AppStore;

// The store-class
abstract class _AppStore with Store {

  final _jsonRepo = JsonRepository();

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

  PackageInfo packageInfo;

  @action
  Future<void> saveProfile(Profile updatedProfile) async {
    await _jsonRepo.set('profile', updatedProfile);
    profile = updatedProfile;
  }

  @computed
  bool get profileConfigured => profile != null;
}
