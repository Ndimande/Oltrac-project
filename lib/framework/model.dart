import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
abstract class Model {
  /// The id assigned by sqlite upon storing.
  final int id;

  /// Default constructor creates a uuid
  @mustCallSuper
  const Model({this.id});

  /// Construct from map. The [Map] must contain id.
  Model.fromMap(Map data) : id = data['id'];

  /// Create a copy with changes.
  Model copyWith();

  /// Get as a map
  Map<String, dynamic> toMap();

  /// Get the model as a string.
  @override
  String toString() => toMap().toString();

  /// Convert the model to a json string.
  String toJson() => jsonEncode(toMap());

  @override
  bool operator ==(other) => other.id?.hashCode == id?.hashCode;

  @override
  int get hashCode => id.hashCode;
}
