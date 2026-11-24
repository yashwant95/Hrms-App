class AppConstants {
  // Live Production Server API URL
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://89.116.34.222:5007/api',
  );
  static const String appName = 'HRMS SaaS';
}
