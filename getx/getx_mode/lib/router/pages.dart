import '../modules/welcome/binding.dart';
import '../modules/welcome/view.dart';
import 'index.dart';

class AppPages {
  static const initial = AppRoutes.initial;

  static final List<GetPage> routes = [
    // 免登陆
    GetPage(
      name: AppRoutes.initial,
      page: () => const WelcomePage(),
      binding: WelcomeBinding(),
    ),
  ];
}
