import 'package:oltrace/models/packaging_type.dart';

/// READ THIS:
/// You can add more entries here or comment out old ones to hide them
/// but do not reuse old IDs
const List<PackagingType> packagingTypes = <PackagingType>[
  PackagingType(id: 1, name: 'Bag'),
  PackagingType(id: 2, name: 'Basket'),
  // do not use 3
  PackagingType(id: 4, name: 'Bin'),
  PackagingType(id: 5, name: 'Box'),
  PackagingType(id: 6, name: 'Carton'),
  PackagingType(id: 7, name: 'Drum'),
  PackagingType(id: 8, name: 'Ring'),
  PackagingType(id: 9, name: 'Unpacked'),
];
