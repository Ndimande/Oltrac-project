import 'package:uuid/uuid.dart';

abstract class Model {
  /// The unique identifier of the model
  final String uuid;

  /// Default constructor creates a uuid
  Model() : uuid = Uuid().v1();

  /// Construct from map. Map must contain UUID.
  Model.fromMap(Map data) : uuid = data['uuid'];

  /// Create a copy with changes
  Model copyWith();

  /// Get as a map
  Map<String, dynamic> toMap();

  /// Get the model as a string
  @override
  String toString() => this.toMap().toString();

  /// Override equality operator to use uuid.
  @override
  bool operator ==(other) {
    return other.uuid == uuid;
  }

  /// Get hash code from uuid
  @override
  int get hashCode => uuid.hashCode;
}
