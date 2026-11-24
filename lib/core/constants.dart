class AppConstants {
  // Live Production Server API URL (Domain with SSL)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://hrmsbackend.fanya.tech/api',
  );
  static const String appName = 'HRMS SaaS';
}
