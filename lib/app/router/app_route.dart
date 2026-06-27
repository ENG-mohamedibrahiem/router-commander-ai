enum AppRoute {
  dashboard('/dashboard'),
  routers('/routers'),
  tools('/tools'),
  connectedDevices('connected-devices'),
  wifi('wifi'),
  dsl('dsl'),
  aiAssistant('/ai'),
  settings('/settings');

  const AppRoute(this.path);

  final String path;
}
