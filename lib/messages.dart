import 'package:oltrace/models/fishing_method_type.dart';
import 'package:oltrace/models/haul.dart';

class Messages {
  static const TRIP_CONFIRM_END = 'Are you sure you want to end the trip?';
  static const TRIP_CONFIRM_CANCEL = 'Are you sure you want to cancel the trip?';

  static const HAUL_CONFIRM_END = 'Are you sure you want to end the haul?';

  static const String LANDING_FIRST_END_DYNAMIC_HAUL =
      'For dynamic fishing methods you must first end the operation before adding species.';
  static const String LANDING_FIRST_SELECT_SPECIES = 'You must first select one or more species to be tagged';

  static const WAITING_FOR_GPS = 'Waiting for GPS. Please be patient.';
  static const LOCATION_NOT_AVAILABLE =
      'Location is not available. Please enable location services on your device and try again.';

  static String endHaulDialogContent(Haul haul) {
    if (haul.fishingMethod.type == FishingMethodType.Dynamic)
      return 'Are you sure you want to end fishing?';
    else
      return 'Are you sure you want to end hauling?';
  }

  static String endHaulTitle(Haul haul) {
    if (haul.fishingMethod.type == FishingMethodType.Dynamic)
      return 'End Fishing';
    else
      return 'End Haul';
  }
}
