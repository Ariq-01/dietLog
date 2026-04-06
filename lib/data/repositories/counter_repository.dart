import '../models/counter_model.dart';
import 'base_repository.dart';

class CounterRepository implements BaseRepository<CounterModel> {
  CounterModel? _cachedData;

  @override
  Future<CounterModel> getData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _cachedData ?? CounterModel(count: 0);
  }

  @override
  Future<void> saveData(CounterModel data) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _cachedData = data;
  }

  @override
  Future<void> deleteData(String id) async {
    _cachedData = null;
  }
}
