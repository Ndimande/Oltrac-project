import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';

@immutable
class Skipper extends Model {
  final String firstName;
  final String lastName;

  const Skipper({@required this.firstName, @required this.lastName});

  @override
  Skipper copyWith({String firstName, String lastName}) {
    return Skipper(
      firstName: firstName ?? firstName,
      lastName: lastName ?? this.lastName,
    );
  }

  Skipper.fromMap(Map data)
      : firstName = data['firstName'],
        lastName = data['lastName'],
        super.fromMap(data);

  @override
  Map<String, dynamic> toMap() {
    return {'firstName': firstName, 'lastName': lastName};
  }
}
