import 'dart:convert';
import 'dart:io';

class RequestBody {
  ContentType toContentType(HttpRequest request) {
    ContentType result;
    switch (request.headers.contentType.value) {
      case "text/plain":
        result = ContentType.text;
        break;
      case "application/json":
        result = ContentType.json;
        break;
      case "text/html":
        result = ContentType.html;
        break;
      default:
    }
    return result;
  }

  Future parse(HttpRequest request) async {
    var content = await request.transform(utf8.decoder).join();
    switch (request.headers.contentType.toString()) {
      case "text/plain":
        return content;

      case "application/json":
        return jsonDecode(content) as Map;

      default:
        return content;
    }
  }
}
