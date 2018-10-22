import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

import 'package:nepuro/src/http/model/Request.dart';
import 'package:nepuro/src/http/model/Route.dart';

class Nepuro {
  //参考
  //https://stackoverflow.com/questions/22740496/in-dart-can-you-retrieve-metadata-e-g-annotations-at-runtime-using-reflecti
  List<Map> _getRoutes() {
    List<Map> routes = new List();
    MirrorSystem ms = currentMirrorSystem();
    ms.libraries.forEach((u, lm) {
      lm.declarations.forEach((s, func) {
        func.metadata.forEach((im) {
          if ((im.reflectee is Route)) {
            routes.add({"route": im.reflectee, "routeFunc": func});
          }
        });
      });
    });
    return routes;
  }

  List _getHitRoute(HttpRequest request, List<Map> routeList) {
    var hitRoute = routeList
        .where((r) =>
            r["route"].path == request.uri.path &&
                request.method == r["route"].method ||
            RegExp("\^${r["route"].path}/.((?!/).)*\$")
                    .hasMatch(request.uri.path) &&
                r["route"].variablePath != null)
        .toList();
    return hitRoute;
  }

  Future _getBody(HttpRequest request) async {
    var content = await request.transform(utf8.decoder).join();
    switch (request.headers.contentType.toString()) {
      case "text/plain":
        return content;

      case "application/json":
        return jsonDecode(content) as Map;

      default:
        return "text/plain";
    }
  }

  server(String ip,int port) async {
    print("start");
    print("http://${ip}:${port}");
    HttpServer.bind(ip, port).then((server) {
      server.listen((HttpRequest request) async {
        HttpResponse response = request.response;

        //@Routeのつく関数をすべて取得しpath,methodが一致する関数のみ取得
        final List<Map> routeList = await _getHitRoute(request, _getRoutes());

        //routeが空でなければ
        if (routeList.isNotEmpty && routeList != null) {
          final Map route = routeList.first;
          print("[${request.method}] ${request.uri.path}");

          //ライブラリの利用者に返すデータ
          Request returnReqData = Request(request, null, null);

          //ライブラリの利用者がvariablePathデータを要求していたら
          if (route["route"].variablePath != null) {
            returnReqData.variablePath = request.uri.pathSegments.last;
          }

          await _getBody(request).then((body) {
            //ライブラリの利用者がbodyデータを要求していたら
            if (route["route"].body != null) {
              //リクエストのbodyが正しいか
              bool isReqBodyCorrect = route["route"].isBodyCorrect(body);

              if (!isReqBodyCorrect) {

                response.headers.set("Content-Type", "text/plain");
                response.statusCode = 400;

                response.write("");
                response.close();

                print("status: 400");
              } else {

                returnReqData.body = body;

                //routeFunc = @Routeがついていてpath,methodが一致する関数
                LibraryMirror owner = route["routeFunc"].owner;
                var routeFunc = owner
                    .invoke(route["routeFunc"].simpleName, [returnReqData]);

                //headerを設定
                response.headers
                    .set("Content-Type", routeFunc.reflectee.contentType);
                response.statusCode = routeFunc.reflectee.status;

                response.write(routeFunc.reflectee.body);
                response.close();

                print("status: ${response.statusCode}");

              }
            }
          });
          
        } else {
          response.headers.set("Content-Type", "text/plain");
          response.statusCode = 404;
          response.write("NOT FOUND");
          response.close();
        }
      });
    });
  }
}
