import 'dart:convert';
import 'dart:io';

Future requestBodyParse(HttpRequest request) async {
  switch (request.headers.contentType.toString()) {
    case "text/plain":
      return await request.transform(utf8.decoder).join();

    case "application/json":
      var content = await request.transform(utf8.decoder).join();
      return jsonDecode(content) as Map;

    default:
      var content = await request.transform(utf8.decoder).join();
      return content;
  }
}
