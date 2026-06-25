enum AppRoute {
  dashboard('/dashboard'),
  routers('/routers'),
  tools('/tools'),
  aiAssistant('/ai'),
  settings('/settings');

  const AppRoute(this.path);

  final String path;
}
