

enum AppRouterPths {
  login(value: 0, routePath: '/login', routeName: '登录'),
  mainWrapper(value: 1, routePath: '/mainWrapper', routeName: '首页'),
  profile(value: 2, routePath: '/profile', routeName: '个人'),
  setting(value: 3, routePath: '/setting', routeName: '设置'),
  task(value: 4, routePath: '/task', routeName: '任务'),
  welcome(value: 5, routePath: '/welcome', routeName: '欢迎'),
  ;

  final int value;
  final String routePath;
  final String routeName;

  const AppRouterPths({
    required this.value,
    required this.routePath,
    required this.routeName,
  });
}

