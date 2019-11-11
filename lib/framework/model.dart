abstract class Model {
  Model();

  Model.fromMap(Map data);

  Model copyWith();

  Map<String, dynamic> toMap();

  @override
  String toString() => this.toMap().toString();

  @override
  bool operator ==(other) {
    return other.toString() == this.toString();
  }

  @override
  int get hashCode => this.toString().hashCode;
}
