import 'package:get_it/get_it.dart';
import 'package:provider_mode/core/store/shared_preferences_service.dart';
import 'package:provider_mode/counter/counter_provider.dart';

final injector = GetIt.instance;

Future<void> initDependencies() async {
  injector.registerFactory(() => CounterProvider());
  injector.registerFactory(() => SharedPreferencesDb());
}
