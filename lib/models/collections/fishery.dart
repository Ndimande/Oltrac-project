import 'package:oltrace/models/fishery.dart';
import 'package:meta/meta.dart';

@immutable
class FisheryCollection {
  final List<Fishery> _fisheries;

  FisheryCollection(this._fisheries);
}
