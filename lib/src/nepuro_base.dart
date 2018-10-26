import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

import 'package:nepuro/src/http/model/Request.dart';
import 'package:nepuro/src/http/model/RouteFunc.dart';

class Nepuro {
  server(String ip, int port) async {
    print("start");
    print("http://${ip}:${port}");

    HttpServer.bind(ip, port).then((server) {
      server.listen((HttpRequest request) async {
        print("[${request.method}] ${request.uri.path}");

        HttpResponse response = request.response;

        //@Routeのつく関数、メタデータをすべて取得
        final List<RouteFunc> routeFuncList = RouteFuncData().getAll();
        //routeListのなかからpath,methodが一致する関数のみ取得
        final RouteFunc routeFunc =
            await RouteFuncData().getMatch(request, routeFuncList);

        //routeが空かNullなら　404を返す
        if (routeFunc == null) {
          response.headers.set("Content-Type", "text/plain");
          response.statusCode = 404;
          response.write("NOT FOUND");
          response.close();

          print("status: 400");
        } else {
          //ライブラリの利用者に返すデータ
          Request returnReqData = Request(request, null, null);

          //ライブラリの利用者がvariablePathデータを要求していたら
          if (routeFunc.metadata.variablePath != null) {
            returnReqData.variablePath = request.uri.pathSegments.last;
          }

          //ライブラリの利用者がbodyデータを要求していたら
          if (routeFunc.metadata.body != null) {
            Map body;

            await _getRequestBody(request).then((requestBody) {
              body = requestBody;
            });

            returnReqData.body = routeFunc.toBodyType(body);

            isBadRequest() {
              //requestのbodyが正しいか
              bool isBodyCorrect = routeFunc.metadata.validateBody(body);

              //mapのvalueが一つでもnullが含まれているかどうか
              var hasNullMapValue =
                  (Map map) => map.values.toList().contains(null);

              //ライブラリの利用者がNecessaryFieldを設定しているかどうか
              bool isEmptyNecessaryField =
                  routeFunc.metadata.necessaryField == null;

              return isEmptyNecessaryField &&
                      hasNullMapValue(returnReqData.body.asMap()) ||
                  !isBodyCorrect && !isEmptyNecessaryField;
            }

            if (isBadRequest()) {
              response.headers.set("Content-Type", "text/plain");
              response.statusCode = 400;
              response.close();

              print("status: 400");
            }
          }

          //すでにresponseが設定されていなければ(デフォルト値なら)
          if (response.statusCode == 200) {
            //routeFuncInvoke = @Routeがついていてpath,methodが一致する関数
            LibraryMirror owner = routeFunc.function.owner;
            var routeFuncInvoke =
                owner.invoke(routeFunc.function.simpleName, [returnReqData]);

            //responseを返す
            routeFuncInvoke.reflectee.send(response);
            print("status: ${response.statusCode}");
          }
        }
      });
    });
  }

  Future _getRequestBody(HttpRequest request) async {
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
