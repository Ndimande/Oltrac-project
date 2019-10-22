import 'package:oltrace/framework/collection.dart';
import 'package:oltrace/models/country.dart';
import 'package:meta/meta.dart';

@immutable
class CountryCollection implements Collection {
  final List<Country> _items;

  CountryCollection(this._items);
}
