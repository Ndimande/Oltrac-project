abstract class Model {
  Model();

  Model.fromMap(Map data);

  Model copyWith();

  Map<String, dynamic> toMap();

  @override
  String toString() => this.toMap().toString();
}
