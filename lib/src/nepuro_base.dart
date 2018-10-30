import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:mirrors';

import 'package:nepuro/src/http/arrayManager.dart';
import 'package:nepuro/src/http/get_field.dart';
import 'package:nepuro/src/http/body_object.dart';
import 'package:nepuro/src/http/route.dart';
import 'package:nepuro/src/http/route_body.dart';

class Nepuro {
  server({String ip = "127.0.0.1", int port = 8080}) async {
    print("start");
    print("http://${ip}:${port}");

    HttpServer.bind(ip, port).then((server) {
      server.listen((HttpRequest request) async {
        print("[${request.method}] ${request.uri.path}");

        HttpResponse response = request.response;

        //@Routeのつく関数、メタデータをすべて取得
        final List<Route> routeList = getRouteList();
        //routeListのなかからpath,methodが一致する関数のみ取得
        final Route route = await getMatchRoute(request, routeList);

        //routeが空かNullなら　404を返す
        if (route == null) {
          response.headers.set("Content-Type", "text/plain");
          response.statusCode = 404;
          response.write("NOT FOUND");
          response.close();

          print("status: 404");
        } else {
          //ライブラリの利用者に返すデータ
          dynamic body;
          Map<String, dynamic> returnReqData = {"body": null, "path": null};

          //ライブラリの利用者がpathデータを要求していたら
          if (route.isCallVarPath) {
            returnReqData["path"] = request.uri.pathSegments.last;
          }

          //ライブラリ利用者がbodyに型を設定していたら
          if (route.isCallBody) {
            //ライブラリ利用者がbodyに設定しているクラスがRequestBodyTypeを実装しているか
            bool isRequestBodyType = getBodyType(route.method)
                .superinterfaces
                .contains(reflectClass(BodyObject));

            //ライブラリ利用者がbodyに設定した型とリクエストの型が一致するかどうか
            var toContentType = () {
              switch (request.headers.contentType.value) {
                case "text/plain":
                  return ContentType.text;
                  break;
                case "application/json":
                  return ContentType.json;
                  break;
                case "text/html":
                  return ContentType.html;
                  break;
                default:
              }
            };
            ContentType requestContentType = toContentType();
            Map<Type, ContentType> contentTypeList = {String: ContentType.text};
            bool isNotCorrectContentType() {
              if (isRequestBodyType && requestContentType == ContentType.json) {
                return false;
              } else if (contentTypeList[
                      getBodyType(route.method).reflectedType] ==
                  requestContentType) {
                return false;
              }

              return true;
            }

            if (isNotCorrectContentType()) {
              response.headers.set("Content-Type", "text/plain");
              response.statusCode = 400;
              response.close();

              print("status: 400,ContentType is not correct");
            } else if (requestContentType == ContentType.text) {
              await _getRequestBody(request).then((requestBody) {
                body = requestBody;
              });
            } else if (isRequestBodyType) {
              await _getRequestBody(request).then((requestBody) {
                body = requestBody;
              });

              isOkRequest() {
                var isNotContainsNull =
                    (Map map) => !map.values.toList().contains(null);

                bool isBodyCorrect = route.requiredField.isEmpty
                    ? true
                    : route.isCorrectBody(body);

                return route.requiredField.isEmpty &&
                        isNotContainsNull(returnReqData["body"].asMap()) ||
                    isBodyCorrect;
              }

              if (isOkRequest()) {
                body = toBodyType(route.method, body);
              } else {
                response.headers.set("Content-Type", "text/plain");
                response.statusCode = 400;
                response.close();

                print("status: 400");
              }
            } else {
              response.headers.set("Content-Type", "text/plain");
              response.statusCode = 400;
              response.close();

              print("status: 400");
            }
          }
          returnReqData["body"] = body;

          //すでにresponseが設定されていなければ(デフォルト値なら)
          if (response.statusCode == 200) {
            //routeFunc = @Routeがついていてpath,methodが一致する関数
            LibraryMirror owner = route.method.owner;
            var routeFunc = owner.invoke(
                route.method.simpleName,
                requDataToFuncField(
                    getMethodFieldNames(route.method), returnReqData));

            //responseを返す
            routeFunc.reflectee.send(response);
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
