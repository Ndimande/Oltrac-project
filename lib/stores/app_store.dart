import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/providers/location.dart';
import 'package:oltrace/repositories/haul.dart';
import 'package:oltrace/repositories/json.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/repositories/landing.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/messages.dart';
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

  final _locationProvider = LocationProvider();

  final Dio dio = Dio();

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
  Future<Product> saveProduct(Product product) async {
    final productId = await _productRepo.store(product);
    final storedProduct = product.copyWith(id: productId);

    // update trip
    final List<Haul> updatedHauls = activeTrip.hauls.map((Haul haul) {
      final List<Landing> updatedLandings = haul.landings.map((Landing landing) {

        if(product.landings.firstWhere((l) => l.id == landing.id) != null) {
          final List<Product> updatedProducts = [...landing.products, storedProduct];
          return landing.copyWith(products: updatedProducts);
        }
        return landing;
      }).toList();

      return haul.copyWith(landings: updatedLandings);
    }).toList();

    final Trip updatedTrip = activeTrip.copyWith(hauls: updatedHauls);

    activeTrip = updatedTrip;

    return storedProduct;
  }

  @action
  Future<void> editLanding(Landing landing) async {
    await _landingRepo.store(landing);

    // update trip
    final List<Haul> updatedHauls = activeTrip.hauls.map((Haul haul) {
      if (haul.id == landing.haulId) {
        final updatedLandings = haul.landings.map((Landing l) {
          if (l.id == landing.id) {
            return landing;
          }
          return l;
        }).toList();
        return haul.copyWith(landings: updatedLandings);
      }
      return haul;
    }).toList();

    final Trip updatedTrip = activeTrip.copyWith(hauls: updatedHauls);

    activeTrip = updatedTrip;
  }

  @action
  Future<Landing> saveLanding(Landing landing) async {
    final landingId = await _landingRepo.store(landing);
    final storedLanding = landing.copyWith(id: landingId);

    // update trip
    final List<Haul> updatedHauls = activeTrip.hauls.map((Haul haul) {
      if (haul.id == storedLanding.haulId) {
        return haul.copyWith(landings: [...haul.landings, storedLanding]);
      }
      return haul;
    }).toList();

    final Trip updatedTrip = activeTrip.copyWith(hauls: updatedHauls);

    activeTrip = updatedTrip;

    return storedLanding;
  }

  @action
  Future<void> deleteLanding(Landing landing) async {
    await _landingRepo.delete(landing.id);
    final List<Haul> updatedHauls = activeTrip.hauls.map((Haul haul) {
      if (haul.id == landing.haulId) {
        haul.landings.remove(landing);
        return haul.copyWith(landings: haul.landings);
      }
      return haul;
    }).toList();

    final Trip updatedTrip = activeTrip.copyWith(hauls: updatedHauls);

    activeTrip = updatedTrip;
  }

  @action
  Future<Haul> startHaul(FishingMethod method) async {
    assert(activeHaul == null);
    assert(activeTrip != null);

    final Location location = await _locationProvider.location;

    if (location == null) {
      throw Exception('Could not get location stream.');
    }

    final haul = Haul(
      fishingMethod: method,
      startedAt: DateTime.now(),
      tripId: activeTrip.id,
      startLocation: location,
    );

    final haulId = await _haulRepo.store(haul);
    final newHaul = haul.copyWith(id: haulId);

    final updatedTrip = activeTrip.copyWith(hauls: [...activeTrip.hauls, newHaul]);

    activeTrip = updatedTrip;

    return haul;
  }

  void _updateActiveTripHaul(Haul haul) {
    final updatedHauls = activeTrip.hauls.map((Haul h) => haul.id == h.id ? haul : h).toList();

    activeTrip = activeTrip.copyWith(hauls: updatedHauls);
  }

  @action
  Future<Haul> endHaul() async {
    // Make sure we don't get a funny state
    if (activeHaul == null) {
      throw Exception("No active haul");
    }

    final Location location = await _locationProvider.location;

    final endedHaul = activeHaul.copyWith(
      endedAt: DateTime.now(),
      tripId: activeTrip.id,
      endLocation: location,
    );

    await _haulRepo.store(endedHaul);

    _updateActiveTripHaul(endedHaul);

    return endedHaul;
  }

  @action
  Future<void> cancelHaul() async {
    // Make sure we don't get a funny state
    assert(hasActiveHaul);

    // Always modify db first
    await _haulRepo.delete(activeHaul.id);

    // remove from trip hauls
    final updatedHauls = activeTrip.hauls;
    updatedHauls.remove(activeHaul);

    activeTrip = activeTrip.copyWith(hauls: updatedHauls);
  }

  // TODO leave the error handling to the widget. Not all widgets have scaffolds and passing them is annoying
  @action
  Future<Trip> startTrip(GlobalKey<ScaffoldState> _scaffoldKey) async {
    _showWaitingForGpsSnackBar(_scaffoldKey);

    try {
      final Location location = await _locationProvider.location;
      _scaffoldKey.currentState.hideCurrentSnackBar();

      final trip = Trip(startedAt: DateTime.now(), startLocation: location);

      final int tripId = await _tripRepo.store(trip);

      activeTrip = trip.copyWith(id: tripId);
    } catch (e) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _showLocationNotAvailableSnackBar(_scaffoldKey);
    }

    return activeTrip;
  }

  @action
  Future<Trip> endTrip() async {
    assert(activeTrip != null);
    assert(activeHaul == null);

    final Location location = await _locationProvider.location;

    final Trip endedTrip = activeTrip.copyWith(endedAt: DateTime.now(), endLocation: location);

    assert(endedTrip.endedAt != null);

    await _tripRepo.store(endedTrip);
    final updatedCompletedTrips = completedTrips;

    assert(endedTrip.endedAt != null);

    // Add ended trip to state
    updatedCompletedTrips.add(endedTrip);
    completedTrips = updatedCompletedTrips;

    activeTrip = null;

    return endedTrip;
  }

  @action
  Future<Trip> cancelTrip() async {

    final trip = activeTrip;

    await _tripRepo.delete(trip.id);
    activeTrip = null;
    return trip;
  }

  @action
  Future<Response> uploadTrip(Trip trip) async {
    // you can't upload an active trip
    assert(!_isActiveTrip(trip));

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    Response response = await dio.post(
      AppConfig.TRIP_UPLOAD_URL,
      data: {
        'datetimereceived': DateFormat('yy-MM-dd HH:mm:ss').format(DateTime.now()),
        'json': {
          'trip': trip.toMap(),
          'user': profile.toMap(),
        }
      },
      options: RequestOptions(headers: {'Content-Type': 'application/json'}),
    );

    await _updateTrip(trip.copyWith(isUploaded: true));
    return response;
  }

  Trip findTrip(int id) {
    if (activeTrip?.id == id) {
      return activeTrip;
    }
    // TODO Too many elements exception. Sometimes two copies of a trip get into the state.
    return completedTrips.singleWhere((Trip t) => t.id == id, orElse: () => null);
  }

  Future<void> _updateTrip(Trip trip) async {
    if (activeTrip?.id == trip.id) {
      activeTrip = trip;
      return;
    }
    await _tripRepo.store(trip);

    final List<Trip> updatedCompletedTrips =
        completedTrips.map((Trip t) => t.id == trip.id ? trip : t).toList();
    completedTrips = updatedCompletedTrips;
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

  void _showWaitingForGpsSnackBar(GlobalKey<ScaffoldState> _scaffoldKey) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(Messages.WAITING_FOR_GPS),
        duration: Duration(minutes: 999), // Show until location is available
      ),
    );
  }

  void _showLocationNotAvailableSnackBar(GlobalKey<ScaffoldState> _scaffoldKey) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(Messages.LOCATION_NOT_AVAILABLE),
      ),
    );
  }

  bool _isActiveTrip(Trip trip) => hasActiveTrip ? activeTrip.id == trip.id : false;
}
