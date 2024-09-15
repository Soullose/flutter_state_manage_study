import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'counter_provider.g.dart';

@riverpod
class CounterProvider extends _$CounterProvider {

  @override
  int build() {
    return 0;
  }

  void increment() => state++;

}