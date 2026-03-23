enum AppRouterPths {
  login(value: 0, routePath: '/login', routeName: '登录'),
  mainWrapper(value: 1, routePath: '/mainWrapper', routeName: '首页'),
  profile(value: 2, routePath: '/profile', routeName: '我的'),
  setting(value: 3, routePath: '/setting', routeName: '设置'),
  task(value: 4, routePath: '/task', routeName: '任务'),
  welcome(value: 5, routePath: '/welcome', routeName: '欢迎'),
  privacy(value: 6, routePath: '/profile/privacy', routeName: '隐私政策'),
  userAgreement(value: 7, routePath: '/profile/agreement', routeName: '用户协议'),
  licenses(value: 8, routePath: '/profile/licenses', routeName: '开源协议');

  final int value;
  final String routePath;
  final String routeName;

  const AppRouterPths({
    required this.value,
    required this.routePath,
    required this.routeName,
  });
}
