import 'dart:async';
import 'dart:developer';

import 'bootstrap.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      await bootstrap();
    },
    (error, stack) {
      return log(error.toString(), stackTrace: stack);
    },
  );
}
