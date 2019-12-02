import 'package:oltrace/framework/model.dart';
import 'package:meta/meta.dart';

@immutable
class Skipper extends Model {
  final String name;

  Skipper({id, this.name}) : super(id: id);

  Skipper.fromMap(Map data)
      : name = data['name'],
        super.fromMap(data);

  Skipper copyWith({String name}) {
    return Skipper(name: name ?? this.name);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  Map<String, dynamic> toDatabaseMap() => toMap();
}
