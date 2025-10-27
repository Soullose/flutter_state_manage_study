abstract class KeyValueDb {
  Future<void> init();

  Future<void> put<T>(String key, T value);

  T get<T>(String key, T defaultValue);
}
