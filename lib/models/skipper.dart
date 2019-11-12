import 'package:oltrace/framework/model.dart';
import 'package:meta/meta.dart';

@immutable
class Skipper extends Model {
  final String name;

  Skipper({this.name});

  Skipper.fromMap(Map data)
      : name = data['name'],
        super.fromMap(data);

  Skipper copyWith({String name}) {
    return Skipper(name: name ?? this.name);
  }

  Map<String, dynamic> toMap() {
    return {'uuid': uuid, 'name': name};
  }
}
