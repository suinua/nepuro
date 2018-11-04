import 'dart:io';
import 'dart:mirrors';

import 'package:nepuro/src/annotation/body_object.dart';
import 'package:nepuro/src/request_body.dart';
import 'package:nepuro/src/response.dart';
import 'package:nepuro/src/route/route.dart';
import 'package:nepuro/src/route/route_body.dart';
import 'package:nepuro/src/route/route_var_path.dart';

class Nepuro {
  server({String ip = "127.0.0.1", int port = 8080}) async {
    print("start");
    print("http://${ip}:${port}");

    var server = await HttpServer.bind(ip, port);

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
      CallBackData callBackData = CallBackData(body:request);

      //ライブラリの利用者がpathデータを要求していたら
      if (route.isCallPathVar) {
        callBackData.pathVar = getPathVar(route.method, request.uri.pathSegments.last);
      }
      print(getPathVarList(request.uri.pathSegments,route));

      //ライブラリの利用者がbodyデータを要求していなければ
      if (!route.isCallBody) {
        route.sendResponse(callBackData, response);
        print("status: ${response.statusCode}");

        return response.statusCode;
      }

      //ライブラリ利用者がbodyに設定しているクラスがRequestBodyTypeを実装しているか
      bool isBodyObject = false;
      getBodyType(route.method).metadata.forEach((metadata){
        if (metadata.reflectee is BodyObject){
          isBodyObject = true;
        }
      });

      //ライブラリ利用者がbodyに設定した型とリクエストの型が一致するかどうか
      String requestContentType = request.headers.contentType.value;

      //ContentTypeがtextならそのまま代入して返す
      if (route.contentType == requestContentType) {
        bool isSuccess;
        await callBackData
            .bodyParse(request.headers.contentType.value)
            .then((result) {
          isSuccess = result;
        });
        if (!isSuccess) {
          Response.badRequest("bad request").send(response);

          print("status: 400");
          return 404;
        }
      }

      //@BodyObjectのついたクラスでない && リクエストのコンテンツタイプがjsonでない
      if (!(isBodyObject && requestContentType == ContentType.json.value)) {
        Response.badRequest("bad request").send(response);

        print("status: 400");
        return 400;
      }

      bool isSuccess;
      await callBackData.bodyParse(request.headers.contentType.value).then((result) {
        isSuccess = result;
      });
      if (!isSuccess) {
        Response.badRequest("bad request").send(response);

        print("status: 400");
        return 404;
      }

      isBadRequest() {
        var isContainNull = (Map map) => map.values.toList().contains(null);

        bool isBodyNotCorrect = route.requiredField.isEmpty
            ? false
            : !route.isCorrectBody(callBackData.body);

        return route.requiredField.isEmpty &&
                isContainNull(callBackData.body.asMap()) ||
            isBodyNotCorrect;
      }

      if (isBadRequest()) {
        Response.badRequest("bad request").send(response);
        print("status: 400");
        return 400;
      }

      callBackData.toSetBodyType(route.method);

      route.sendResponse(callBackData, response);
      print("status: ${response.statusCode}");
      return 200;
    });
  }
}
