import 'dart:io';
import 'dart:mirrors';

import 'package:nepuro/src/http/body_object.dart';
import 'package:nepuro/src/http/request_body.dart';
import 'package:nepuro/src/http/response.dart';
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
          Response.notFound("not found").send(response);
          print("status: 404");

          return 404;
        }

        //ライブラリの利用者に返すデータ
        dynamic body;
        Map<String, dynamic> returnReqData = {"body": null, "path": null};

        //ライブラリの利用者がpathデータを要求していたら
        if (route.isCallVarPath) {
          returnReqData["path"] = request.uri.pathSegments.last;
        }

        //ライブラリ利用者がbodyに型を設定していなければ
        if (!route.isCallBody) {
          route.sendResponse(returnReqData, response);
          print("status: ${response.statusCode}");

          return response.statusCode;
        }

        //ライブラリ利用者がbodyに設定しているクラスがRequestBodyTypeを実装しているか
        bool isBodyObject = getBodyType(route.method)
            .superinterfaces
            .contains(reflectClass(BodyObject));

        //ライブラリ利用者がbodyに設定した型とリクエストの型が一致するかどうか
        ContentType requestContentType = RequestBody().toContentType(request);
        Map<Type, ContentType> contentTypeList = {String: ContentType.text};
        bool isNotCorrectContentType() {
          if (isBodyObject && requestContentType == ContentType.json) {
            return false;
          } else if (contentTypeList[getBodyType(route.method).reflectedType] ==
              requestContentType) {
            return false;
          }
          return true;
        }

        //一致していなければ400
        if (isNotCorrectContentType()) {
          Response.badRequest("bad request").send(response);
          print("status: 400");
          return 400;
        }

        //ContentTypeがtextならそのまま代入して返す
        if (requestContentType == ContentType.text) {
          await RequestBody().parse(request).then((requestBody) {
            returnReqData["body"] = requestBody;
          });
          route.sendResponse(returnReqData, response);
          print("status: ${response.statusCode}");

          return response.statusCode;
        }

        //
        if (!isBodyObject) {
          Response.badRequest("bad request").send(response);

          print("status: 400");
          return 400;
        }

        await RequestBody().parse(request).then((requestBody) {
          body = requestBody;
        });

        isBadRequest() {
          var isContainNull = (Map map) => map.values.toList().contains(null);

          bool isBodyNotCorrect =
              route.requiredField.isEmpty ? false : !route.isCorrectBody(body);

          return route.requiredField.isEmpty &&
                  isContainNull(returnReqData["body"].asMap()) ||
              isBodyNotCorrect;
        }

        if (isBadRequest()) {
          Response.badRequest("bad request").send(response);
          print("status: 400");
          return 400;
        }

        returnReqData["body"] = toBodyType(route.method, body);
        route.sendResponse(returnReqData, response);
        print("status: ${response.statusCode}");
        return 200;
      });
    });
  }
}
