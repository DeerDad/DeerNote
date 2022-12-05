import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';

class HttpClient {
  static http.Client createHttpClient() {
    http.Client _client = http.Client();
    if (_client is BrowserClient) {
      (_client as BrowserClient).withCredentials = true;
    }
    return _client;
  }
}
