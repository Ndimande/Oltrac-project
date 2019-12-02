import 'dart:convert';
import 'package:uuid/uuid.dart';

abstract class Model {
  /// The id assigned by sqlite upon storing.
  final int id;

  /// Default constructor creates a uuid
  const Model({this.id});

  /// Construct from map. The [Map] must contain id.
  Model.fromMap(Map data) : id = data['id'];

  /// Create a copy with changes.
  Model copyWith();

  /// Get as a map
  Map<String, dynamic> toMap();

  /// Get the model as a string.
  @override
  String toString() => this.toMap().toString();

  /// Convert the model to a json string.
  String toJson() => jsonEncode(this.toMap());
}
