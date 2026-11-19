/// Dirección configurable desde --dart-define=API_BASE_URL=...
abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.ehily.cecar.cloud',
  );
}
