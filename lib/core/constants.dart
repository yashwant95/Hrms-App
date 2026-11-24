class AppConstants {
  // Use host machine LAN IP for physical device testing over Wi-Fi, configurable via dart-define
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.29.83:5000/api',
  );
  static const String appName = 'HRMS SaaS';
}
