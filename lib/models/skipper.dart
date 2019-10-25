import 'package:oltrace/framework/model.dart';
import 'package:uuid/uuid.dart';
import 'package:meta/meta.dart';

@immutable
class Skipper extends Model {
  final String uuid;
  final String name;

  Skipper({this.name}) : this.uuid = Uuid().v1();

  Skipper.fromMap(Map data)
      : uuid = data['uuid'],
        name = data['name'];

  Skipper copyWith({String name}) {
    return Skipper(name: name ?? this.name);
  }

  Map<String, dynamic> toMap() {
    return {'id': uuid, 'name': name};
  }
}
