import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_mode/common/net/http_client.dart';

import '../counter_provider.dart';

class CounterPage extends ConsumerWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int count = ref.watch(counterProvider.select((count) => count));
    return Scaffold(
      appBar: AppBar(title: const Text('Counter example')),
      body: Center(
        child: Text('计数:$count'),
      ),
      floatingActionButton: FloatingActionButton(
        // The read method is a utility to read a provider without listening to it
        onPressed: () async {
          ref.read(counterProvider.notifier).increment();
          final dio = Dio();
          final response = await dio.get('https://dart.dev');
          debugPrint('response:$response');
          final asyncValue = ref.watch(netFetchProvider(
              url: 'https://www.wanandroid.com/article/list/0/json')).value;
          debugPrint('response:${asyncValue?.data}');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
