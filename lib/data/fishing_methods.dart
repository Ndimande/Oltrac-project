import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/models/fishing_method_type.dart';

const List<FishingMethod> fishingMethods = <FishingMethod>[
  FishingMethod(
    id: 1,
    name: 'Beach seine',
    abbreviation: 'SB',
    type: FishingMethodType.Dynamic,
  ),
  FishingMethod(
    id: 2,
    name: 'Boat seine',
    abbreviation: 'SV',
    type: FishingMethodType.Dynamic,
  ),
  FishingMethod(
    id: 3,
    name: 'Beam trawl',
    abbreviation: 'TBB',
    type: FishingMethodType.Dynamic,
  ),
  FishingMethod(
    id: 4,
    name: 'Single boat bottom otter trawl',
    abbreviation: 'OTB',
    type: FishingMethodType.Dynamic,
  ),
  FishingMethod(
    id: 5,
    name: 'Set gillnet (anchored)',
    abbreviation: 'GNS',
    type: FishingMethodType.Static,
  ),
  FishingMethod(
    id: 6,
    name: 'Drift gillnet',
    abbreviation: 'GND',
    type: FishingMethodType.Static,
  ),
  FishingMethod(
    id: 7,
    name: 'Set longline',
    abbreviation: 'LLS',
    type: FishingMethodType.Static,
  ),
  FishingMethod(
    id: 8,
    name: 'Drifting longline',
    abbreviation: 'LLD',
    type: FishingMethodType.Static,
  )
];
