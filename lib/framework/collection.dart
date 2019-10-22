import 'package:oltrace/framework/model.dart';
import 'package:meta/meta.dart';

@immutable
abstract class Collection {
  final List<Model> _items;

  Collection(this._items);
}
