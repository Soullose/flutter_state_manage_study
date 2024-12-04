import 'package:flutter/foundation.dart';
import 'package:getx_mode/router/index.dart';

class WelcomeController extends GetxController {
  static WelcomeController get to => Get.find();

  final welcomeTitle = "零件扫描";

  @override
  void onReady() {
    super.onReady();
    if (kDebugMode) {
      print('Welcome Controller');
    }

    Future.delayed(
        const Duration(seconds: 1), () => Get.offAllNamed('/app'));
  }
}
