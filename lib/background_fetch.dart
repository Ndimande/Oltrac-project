import 'package:background_fetch/background_fetch.dart';
import 'package:connectivity/connectivity.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:oltrace/app_data.dart';
import 'package:oltrace/http/ddm.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/models/trip_upload.dart';
import 'package:oltrace/providers/user_prefs.dart';
import 'package:oltrace/repositories/trip.dart';

// Todo: Headless uploads
Future<void> backgroundFetchHeadlessTask(String taskId) async {
  print('[BackgroundFetch] Headless event received $taskId');
  print('Headless Trip uploads will come in a future version');

  BackgroundFetch.finish(taskId);
}

Future<void> backgroundFetchCallback(String taskId) async {
  print("[BackgroundFetch] Event received $taskId");
  await _uploadCompletedTrips();
}

Future<void> _uploadCompletedTrips() async {
  final userPrefs = UserPrefsProvider().userPrefs;

  if (userPrefs.uploadAutomatically != true) {
    print('[BackgroundFetch] Upload automatically is disabled. No trips uploaded.');
    return;
  }

  final ConnectivityResult connectivity = await Connectivity().checkConnectivity();

  if (connectivity == ConnectivityResult.none) {
    print('[BackgroundFetch] No connection available. No trips uploaded.');
    return;
  }

  if (connectivity == ConnectivityResult.mobile && !userPrefs.mobileData) {
    print('[BackgroundFetch] Upload with mobile data disabled. No trips uploaded.');
    return;
  }

  final tripRepo = TripRepository();

  // Get completed Trips that have not been uploaded
  final List<Trip> pendingTrips = await TripRepository().all(where: 'is_uploaded = 0 AND ended_at IS NOT NULL');

  if (pendingTrips.isEmpty) {
    print('[BackgroundFetch] No Trips pending upload');
    return;
  }

  for (final Trip tripToUpload in pendingTrips) {
    final data = TripUploadData(trip: tripToUpload);

    await DdmApi.uploadTrip(data);

    await tripRepo.store(tripToUpload.copyWith(isUploaded: true));

    print('[BackgroundFetch] Trip ${tripToUpload.id} was uploaded in the background.');
  }
}
