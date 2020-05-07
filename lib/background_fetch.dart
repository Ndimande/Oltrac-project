import 'package:background_fetch/background_fetch.dart';
import 'package:oltrace/http/ddm.dart';
import 'package:oltrace/models/master_container.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/stores/app_store.dart';

Future<void> backgroundFetchHeadlessTask(String taskId) async {
  print('[BackgroundFetch] Headless event received.');
  await _uploadNextTrip();
  BackgroundFetch.finish(taskId);
}

Future<void> backgroundFetchCallback(String taskId) async {
  print("[BackgroundFetch] Event received $taskId");
  await _uploadNextTrip();
}

Future<void> _uploadNextTrip() async {
  final AppStore _appStore = StoreProvider().appStore;
  final tripRepo = TripRepository();
  final List<Trip> pendingTrips = await TripRepository().all(where: 'is_uploaded = 0');

  if (pendingTrips.isEmpty) {
    print('No Trips pending trips to upload in background');
    return;
  }

  for(final Trip tripToUpload in pendingTrips) {

    final List<MasterContainer> mcs = await tripRepo.masterContainers(tripToUpload.id);
    final data = UploadTripData(
      json: UploadTripDataJson(
        trip: UploadTripDataJsonTrip(masterContainers: mcs),
        user: _appStore.profile.toMap(),
      ),
    );

    await DdmApi.uploadTrip(data);

    await tripRepo.store(tripToUpload.copyWith(isUploaded: true));

    print('Trip uploaded in background ${tripToUpload.id}');
  }
}
