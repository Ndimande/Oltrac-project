import 'package:connectivity/connectivity.dart';
import 'package:oltrace/http/ddm.dart';
import 'package:oltrace/models/master_container.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/models/trip_upload.dart';
import 'package:oltrace/providers/user_prefs.dart';
import 'package:oltrace/repositories/master_container.dart';
import 'package:oltrace/repositories/trip.dart';

class TripUploadService {
  static final _userPrefs = UserPrefsProvider().userPrefs;

  static Future<void> uploadPendingTrips() async {
    final ConnectivityResult connectivity = await Connectivity().checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      print('[TripUploadService] No connection available. No trips uploaded.');
      return;
    }

    if (connectivity == ConnectivityResult.mobile && !_userPrefs.mobileData) {
      print('[TripUploadService] Upload with mobile data disabled. No trips uploaded.');
      return;
    }

    final List<Trip> pendingTrips = await _getTripsPendingUpload();

    if (pendingTrips.isEmpty) {
      print('[TripUploadService] No Trips pending upload');
      return;
    }

    for (final Trip trip in pendingTrips) {
      await uploadTrip(trip);
    }
  }

  static Future<void> uploadTrip(Trip trip) async {
    final List<MasterContainer> masterContainers = await MasterContainerRepository().forTrip(trip.id);
    final withMCs = trip.copyWith(masterContainers: masterContainers);
    final data = TripUploadData(trip: withMCs);

    await DdmApi.uploadTrip(data);

    final uploadedTrip = await TripRepository().store(trip.copyWith(isUploaded: true));
    return uploadedTrip;
  }

  static Future<List<Trip>> _getTripsPendingUpload() async {
    return await TripRepository().all(where: 'is_uploaded = 0 AND ended_at IS NOT NULL');
  }
}
