import 'package:flutter/material.dart';
import 'package:oltrace/framework/model.dart';
import 'package:uuid/uuid.dart';

@immutable
class Tag extends Model {
  final String uuid;
  final String tagId;

  Tag({this.tagId}) : this.uuid = Uuid().v1();

  Tag copyWith({String tagId}) {
    return Tag(tagId: tagId);
  }

  Map<String, dynamic> toMap() {
    return {'tagId': tagId};
  }
}
