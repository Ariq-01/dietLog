abstract class BaseRepository<T> {
  Future<T> getData();
  Future<void> saveData(T data);
  Future<void> deleteData(String id);
}
