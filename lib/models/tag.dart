import 'package:flutter/material.dart';
import 'package:oltrace/framework/model.dart';

@immutable
class Tag extends Model {
  final String tagId;

  Tag({this.tagId});

  Tag.fromMap(Map data)
      : tagId = data['tagId'],
        super.fromMap(data);

  Tag copyWith({String tagId}) {
    return Tag(tagId: tagId);
  }

  Map<String, dynamic> toMap() {
    return {'uuid': uuid, 'tagId': tagId};
  }
}
