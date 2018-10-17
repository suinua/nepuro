
import 'dart:io';
import 'dart:mirrors';

import 'package:nepuro/src/http/model/Route.dart';

Nepuro() {
  print("start..");
  HttpServer.bind("127.0.0.1", 8080).then((server) {
    server.listen((HttpRequest request) {
      
      var routeList = getRoutes();
      var route = routeList
          .where((r) => r.path == request.uri.path && request.method == r.method)
          .toList();

      HttpResponse response = request.response;
      if (route.isNotEmpty) {
        print("[${request.method}] ${request.uri.path}");

        LibraryMirror owner = route[0].responseFunc.owner;
        var responseFunc = owner.invoke(route[0].responseFunc.simpleName, []);

        response.headers.set("Content-Type", responseFunc.reflectee.contentType);

        response.write(responseFunc.reflectee.body);
        response.close();
      } else {
        response.headers.set("Content-Type", "text/plain");
        response.statusCode = 404;
        response.write("NOT FOUND");
        response.close();
      }
    });
  });
}
