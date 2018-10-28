import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

import 'package:nepuro/src/http/arrayManager.dart';
import 'package:nepuro/src/http/classManager.dart';
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
          Map<String, dynamic> returnReqData = {
            "body": null,
            "path": null
          };

          //ライブラリの利用者がpathデータを要求していたら
          if (routeFunc.isNeedOfPath()) {
            returnReqData["path"] = request.uri.pathSegments.last;
          }

          //ライブラリの利用者がnecessaryFieldのみ設定していたら
          if (routeFunc.isNotNeedOfBody() &&
              routeFunc.isNeedOfNecessaryField()) {
            await _getRequestBody(request).then((requestBody) {
              returnReqData["body"] = requestBody;
            });

            if (!routeFunc.validateBody(returnReqData["body"])) {
              response.headers.set("Content-Type", "text/plain");
              response.statusCode = 400;
              response.close();

              print("status: 400");
            }
            //ライブラリの利用者がbodyデータを要求していたら
          } else if (routeFunc.isNeedOfBody()) {
            dynamic body;

            await _getRequestBody(request).then((requestBody) {
              body = requestBody;
            });
              //bodyがnullでなければ
              //ライブラリ利用者が要求しているタイプにbodyを変換
              if (routeFunc.isNeedOfBody()) {
                returnReqData["body"] = routeFunc.toBodyType(body);
              } else {
                returnReqData["body"] = body;
              }

              isBadRequest() {
                //mapのvalueが一つでもnullが含まれているかどうか
                var hasNullMapValue =
                    (Map map) => map.values.toList().contains(null);

                //NecessaryFieldが空で無い
                //リクエストのbodyが正しくない
                bool isBodyNotCorrect = routeFunc.isNotNeedOfNecessaryField()
                    ? false
                    : !routeFunc.validateBody(body);
              print(routeFunc.validateBody(body));

                //NecessaryFieldがNull(bodyのNullは禁止) && bodyにNullが含まれる
                //Bodyが正しくない
                return routeFunc.isNotNeedOfNecessaryField() &&
                        hasNullMapValue(returnReqData["body"].asMap()) ||
                    isBodyNotCorrect;
              
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
            LibraryMirror owner = routeFunc.method.owner;
            var routeFuncInvoke =
                owner.invoke(routeFunc.method.simpleName, requDataToFuncField(getMethodFieldNames(routeFunc.method), returnReqData));

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
