class CounterModel {
  final int count;

  CounterModel({this.count = 0});

  CounterModel copyWith({int? count}) {
    return CounterModel(count: count ?? this.count);
  }
}
