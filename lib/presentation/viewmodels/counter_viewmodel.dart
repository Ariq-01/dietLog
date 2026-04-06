import '../../data/models/counter_model.dart';
import '../../data/repositories/counter_repository.dart';
import 'base_viewmodel.dart';

class CounterViewModel extends BaseViewModel {
  final CounterRepository _repository;
  CounterModel _counter = CounterModel();

  CounterViewModel({CounterRepository? repository})
    : _repository = repository ?? CounterRepository();

  int get count => _counter.count;

  Future<void> loadCounter() async {
    setLoading(true);
    try {
      _counter = await _repository.getData();
      clearError();
    } catch (e) {
      setError('Failed to load counter: $e');
    } finally {
      setLoading(false);
    }
  }

  void increment() {
    _counter = _counter.copyWith(count: _counter.count + 1);
    _repository.saveData(_counter);
    notifyListeners();
  }

  void decrement() {
    _counter = _counter.copyWith(count: _counter.count - 1);
    _repository.saveData(_counter);
    notifyListeners();
  }

  void reset() {
    _counter = CounterModel(count: 0);
    _repository.saveData(_counter);
    notifyListeners();
  }
}
