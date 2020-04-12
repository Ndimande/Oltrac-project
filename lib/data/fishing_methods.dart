import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/models/fishing_method_type.dart';

const List<FishingMethod> fishingMethods = <FishingMethod>[
  FishingMethod(
    id: 1,
    name: 'Beach Seine',
    abbreviation: 'SB',
    type: FishingMethodType.Dynamic,
  ),
  FishingMethod(
    id: 2,
    name: 'Boat Seine',
    abbreviation: 'SV',
    type: FishingMethodType.Dynamic,
  ),
  FishingMethod(
    id: 3,
    name: 'Beam Trawl',
    abbreviation: 'TBB',
    type: FishingMethodType.Dynamic,
  ),
  FishingMethod(
    id: 4,
    name: 'Single Boat Bottom Otter Trawl',
    abbreviation: 'OTB',
    type: FishingMethodType.Dynamic,
  ),
  FishingMethod(
    id: 5,
    name: 'Gillnets Anchored',
    abbreviation: 'GNS',
    type: FishingMethodType.Static,
  ),
  FishingMethod(
    id: 6,
    name: 'Drift Gillnet',
    abbreviation: 'GND',
    type: FishingMethodType.Static,
  ),
  FishingMethod(
    id: 7,
    name: 'Bottom Longline',
    abbreviation: 'LLS',
    type: FishingMethodType.Static,
  ),
  FishingMethod(
    id: 8,
    name: 'Drifting Longline',
    abbreviation: 'LLD',
    type: FishingMethodType.Static,
  )
];
