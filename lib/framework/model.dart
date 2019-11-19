import 'dart:convert';

import 'package:uuid/uuid.dart';

abstract class Model {
  /// The unique identifier of the model instance.
  final String uuid;

  /// The id assigned by sqlite upon storing.
  final int id;

  /// Default constructor creates a uuid
  Model({this.id}) : uuid = Uuid().v1();

  /// Construct from map. Map must contain UUID.
  Model.fromMap(Map data)
      : id = data['id'],
        uuid = data['uuid'];

  /// Create a copy with changes.
  Model copyWith();

  /// Get as a map
  Map<String, dynamic> toMap();

  /// Get the model as a string.
  @override
  String toString() => this.toMap().toString();

  /// Override equality operator to use uuid.
  @override
  bool operator ==(other) {
    return other.uuid == uuid;
  }

  /// Get hash code from uuid.
  @override
  int get hashCode => uuid.hashCode;

  /// Convert the model to a json string.
  String toJson() => jsonEncode(this.toMap());
}
