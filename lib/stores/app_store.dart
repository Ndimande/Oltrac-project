import 'package:geolocator/geolocator.dart';
import 'package:mobx/mobx.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/repositories/haul.dart';
import 'package:oltrace/repositories/json.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/repositories/landing.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:package_info/package_info.dart';

// Include generated file
part 'app_store.g.dart';

// This is the class used by rest of your codebase
class AppStore = _AppStore with _$AppStore;

// The store-class
abstract class _AppStore with Store {
  final _tripRepo = TripRepository();
  final _haulRepo = HaulRepository();
  final _landingRepo = LandingRepository();
  final _jsonRepo = JsonRepository();
  final _productRepo = ProductRepository();

  final Geolocator geoLocator = Geolocator()..forceAndroidLocationManager = true;

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
  Future<Product> saveProduct(Product product) async {
    final productId = await _productRepo.store(product);
    final storedProduct = product.copyWith(id: productId);

    // update trip
    final List<Haul> updatedHauls = activeTrip.hauls.map((Haul haul) {
      final List<Landing> updatedLandings = haul.landings.map((Landing landing) {
        final List<Product> updatedProducts = [
          ...landing.products,
          storedProduct
        ];
        return landing.copyWith(products: updatedProducts);
      }).toList();

      return haul.copyWith(landings: updatedLandings);
    }).toList();

    final Trip updatedTrip = activeTrip.copyWith(hauls: updatedHauls);

    activeTrip = updatedTrip;

    return storedProduct;
  }

  @action
  Future<Landing> saveLanding(Landing landing) async {
    final landingId = await _landingRepo.store(landing);
    landing = landing.copyWith(id: landingId);

    // update trip
    final List<Haul> updatedHauls = activeTrip.hauls.map((Haul haul) {
      if (haul.id == landing.haulId) {
        return haul.copyWith(landings: [...haul.landings, landing]);
      }
      return haul;
    }).toList();

    final Trip updatedTrip = activeTrip.copyWith(hauls: updatedHauls);

    activeTrip = updatedTrip;

    return landing;
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

    final haulId = await _haulRepo.store(haul);
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

    if (await geoLocator.isLocationServiceEnabled() == false) {
      throw Exception('Location service is not enabled');
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

    await _haulRepo.store(endedHaul);

    final updatedHauls = activeTrip.hauls.map((Haul haul) {
      if (haul.id == endedHaul.id) {
        return endedHaul;
      }
      return haul;
    }).toList();

    // update state
    activeTrip = activeTrip.copyWith(hauls: updatedHauls);

    return endedHaul;
  }

  @action
  Future<void> cancelHaul() async {
    // Make sure we don't get a funny state
    assert(activeHaul != null);
    // we will need to delete from db first
    await _haulRepo.delete(activeHaul.id);
    // remove from trip hauls
    final updatedHauls = activeTrip.hauls;
    updatedHauls.remove(activeHaul);

    activeTrip = activeTrip.copyWith(hauls: updatedHauls);
  }

  @action
  Future<Trip> startTrip() async {
    Position position = await geoLocator.getLastKnownPosition();

    if (position == null) {
      // This can take a few seconds
      position = await geoLocator.getCurrentPosition();
    }

    final trip = Trip(startedAt: DateTime.now(), startPosition: position);

    final int tripId = await _tripRepo.store(trip);

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

    await _tripRepo.store(endedTrip);

    // If the trip is being ended, Haul must be ended
    if (activeHaul != null) {
      await endHaul();
    }

    assert(activeHaul == null);

    // avert your eyes
    if (completedTrips.length == 0) {
      completedTrips = [endedTrip];
    } else {
      completedTrips = [...completedTrips, endedTrip];
    }

    activeTrip = null;

    return endedTrip;
  }

  @action
  Future<Trip> cancelTrip() async {
    assert(hasActiveTrip != null);
    final trip = activeTrip;

    await _tripRepo.delete(trip.id);
    activeTrip = null;
    return trip;
  }

  @action
  Future<void> saveProfile(Profile updatedProfile) async {
    await _jsonRepo.set('profile', updatedProfile);
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
  int get activeTripLandingsCount {
    if (activeTrip == null) {
      throw new Exception('No active trip');
    }
    if (activeTrip.hauls.length == 0 && activeHaul == null) {
      return 0;
    }
    return activeTrip.hauls.fold(0, (int total, Haul elem) => total + elem.landings.length);
  }

  PackageInfo packageInfo;
}
