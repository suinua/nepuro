import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

import 'package:nepuro/src/http/arrayManager.dart';
import 'package:nepuro/src/http/classManager.dart';
import 'package:nepuro/src/http/model/RequestBodyType.dart';
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

          print("status: 404");
        } else {
          //ライブラリの利用者に返すデータ
          Map<String, dynamic> returnReqData = {"body": null, "path": null};

          //ライブラリの利用者がpathデータを要求していたら
          if (routeFunc.isNeedOfPath()) {
            returnReqData["path"] = request.uri.pathSegments.last;
          }

          if (routeFunc.isNeedOfBody()) {
            dynamic body;

            await _getRequestBody(request).then((requestBody) {
              body = requestBody;
            });
            //ライブラリ利用者がbodyを要求していて
            //ライブラリ利用者がbodyに設定しているクラスがRequestBodyTypeを実装していたら
            //ライブラリ利用者が要求しているタイプにbodyを変換
            bool isRequestBodyType = routeFunc
                .getBodyType()
                .superinterfaces
                .contains(reflectClass(RequestBodyType));

            //ライブラリ利用者がbodyに設定した型とリクエストの型が一致するかどうか
            bool isNotCorrectContentType() {
              Map contentTypeList = {String: ContentType.text};
              if (isRequestBodyType && request.headers.contentType.value == ContentType.json.value) {
                return false;
              }else if (contentTypeList[routeFunc.getBodyType().reflectedType] ==
                  request.headers.contentType) {
                return false;
              }

              return true;
            }

            if (isNotCorrectContentType()) {
              response.headers.set("Content-Type", "text/plain");
              response.statusCode = 400;
              response.close();

              print("status: 400");
            } else {
              isBadRequest() {
                //mapのvalueが一つでもnullが含まれているかどうか
                var hasNullMapValue =
                    (Map map) => map.values.toList().contains(null);

                //NecessaryFieldが空で無い
                //リクエストのbodyが正しくない
                bool isBodyNotCorrect = routeFunc.isNotNeedOfNecessaryField()
                    ? false
                    : !routeFunc.isCorrectBody(body);
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
              } else {
                //bodyをセット
                if (isRequestBodyType) {
                  returnReqData["body"] = routeFunc.toBodyType(body);
                } else {
                  returnReqData["body"] = body;
                }
              }
            }
          }

          //すでにresponseが設定されていなければ(デフォルト値なら)
          if (response.statusCode == 200) {
            //routeFuncInvoke = @Routeがついていてpath,methodが一致する関数
            LibraryMirror owner = routeFunc.method.owner;
            var routeFuncInvoke = owner.invoke(
                routeFunc.method.simpleName,
                requDataToFuncField(
                    getMethodFieldNames(routeFunc.method), returnReqData));

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
