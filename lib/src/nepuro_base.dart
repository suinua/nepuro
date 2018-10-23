import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

import 'package:nepuro/src/http/model/Request.dart';
import 'package:nepuro/src/http/model/Route.dart';

class Nepuro {
  server(String ip, int port) async {
    print("start");
    print("http://${ip}:${port}");

    HttpServer.bind(ip, port).then((server) {
      server.listen((HttpRequest request) async {
        HttpResponse response = request.response;

        //@Routeのつく関数をすべて取得しpath,methodが一致する関数のみ取得
        final List<Map> routeList = await _getHitRoute(request, _getRoutes());

        //routeが空かNullなら　404を返す
        if (routeList.isEmpty || routeList == null) {
          response.headers.set("Content-Type", "text/plain");
          response.statusCode = 404;
          response.write("NOT FOUND");
          response.close();
        } else {
          final Map route = routeList.first;
          print("[${request.method}] ${request.uri.path}");

          //ライブラリの利用者に返すデータ
          Request returnReqData = Request(request, null, null);

          //ライブラリの利用者がvariablePathデータを要求していたら
          if (route["data"].variablePath != null) {
            returnReqData.variablePath = request.uri.pathSegments.last;
          }

          //ライブラリの利用者がbodyデータを要求していたら
          if (route["data"].body != null) {
            await _getBody(request).then((body) {
              //リクエストのbodyが正しいか
              bool isReqBodyCorrect = route["data"].isCorrectBody(body);

              //正しければbodyを代入
              if (isReqBodyCorrect) {
                returnReqData.body = body;

                //正しくなければ404エラーを返す
              } else {
                response.headers.set("Content-Type", "text/plain");
                response.statusCode = 400;
                response.write("");
                response.close();

                print("status: 400");
              }
            });
          }

          //responseFunc = @Routeがついていてpath,methodが一致する関数
          LibraryMirror owner = route["response"].owner;
          var responseFunc =
              owner.invoke(route["response"].simpleName, [returnReqData]);

          //すでにresponseが設定されていなければ
          if (response.statusCode != 400) {
            //responseを返す
            responseFunc.reflectee.send(response);
            print("status: ${response.statusCode}");
          }
        }
      });
    });
  }

  //参考
  //https://stackoverflow.com/questions/22740496/in-dart-can-you-retrieve-metadata-e-g-annotations-at-runtime-using-reflecti
  List<Map> _getRoutes() {
    List<Map> routes = new List();
    MirrorSystem ms = currentMirrorSystem();
    ms.libraries.forEach((u, lm) {
      lm.declarations.forEach((s, func) {
        func.metadata.forEach((im) {
          if ((im.reflectee is Route)) {
            routes.add({"data": im.reflectee, "response": func});
          }
        });
      });
    });
    return routes;
  }

  List _getHitRoute(HttpRequest request, List<Map> routeList) {
    var hitRoute = routeList
        .where((r) =>
              r["data"].variablePath == null &&
                r["data"].path == request.uri.path &&
                request.method == r["data"].method ||
            RegExp("\^${r["data"].path}/.((?!/).)*\$")
                    .hasMatch(request.uri.path) &&
                r["data"].variablePath != null &&
                request.method == r["data"].method)
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
}
