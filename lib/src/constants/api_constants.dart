class ApiConstants {
  // -------------------------------------------------------
  // Change this to match your environment:
  // Android emulator → 'http://10.0.2.2:8000'
  // iOS simulator    → 'http://127.0.0.1:8000'
  // Physical device  → 'http://YOUR_PC_LOCAL_IP:8000'  e.g. http://192.168.1.5:8000
  // Production       → 'https://yourdomain.com'
  // -------------------------------------------------------
  static const String baseUrl = 'https://www.its.ac.id/tsipil/informasibanjir/public';

  // Endpoints
  static const String register   = '$baseUrl/api/mobile/register';
  static const String login      = '$baseUrl/api/mobile/login';
  static const String logout     = '$baseUrl/api/mobile/logout';
  static const String me         = '$baseUrl/api/mobile/me';
  static const String entry      = '$baseUrl/api/mobile/entry';
  static const String surveys    = '$baseUrl/api/mobile/surveys';
  static const String categories = '$baseUrl/api/mobile/categories';
}