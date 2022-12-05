import 'package:http/http.dart' as http;

class HttpClient {
  static http.Client createHttpClient() {
    http.Client _client = http.Client();
    return _client;
  }
}
