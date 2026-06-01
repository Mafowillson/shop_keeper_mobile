class AppConfig {
  AppConfig._();

  // Physical device on the same WiFi: use the host machine's local IP.
  // Android emulator: use 'http://10.0.2.2:8080/api/v1'
  // Production VPS: use 'https://your-domain.com/api/v1'
  static const String baseUrl = 'http://192.168.1.161:8080/api/v1';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
