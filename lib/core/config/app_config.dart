abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'FLUXA_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:18080',
  );
}
