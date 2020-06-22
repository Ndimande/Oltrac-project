import 'package:oltrace/models/product_type.dart';

/// Product types that can be selected
/// READ THIS:
/// You can add more entries here or comment out old ones to hide them
/// but do not reuse old IDs
const List<ProductType> productTypes = <ProductType>[
  ProductType(id: 1, name: 'Whole'),
  ProductType(id: 2, name: 'Meat'),
  // do not use 3
  ProductType(id: 4, name: 'Fins Primary'),
  ProductType(id: 5, name: 'Fins Secondary'),
  ProductType(id: 8, name: 'Liver Oil'),

  /// These are just for posterity.
  /// They may be turned on again but not removed.
  //ProductType(id: 9, name: 'Teeth'),
  //ProductType(id: 10, name: 'Jaws'),
  //ProductType(id: 11, name: 'Bait'),
  //ProductType(id: 12, name: 'Fish meal'),

  ProductType(id: 14, name: 'Trunk – fins on'),
  ProductType(id: 15, name: 'Trunk – fins off'),
  ProductType(id: 13, name: 'Other'),
];