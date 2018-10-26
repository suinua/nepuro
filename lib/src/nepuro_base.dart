import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

import 'package:nepuro/src/http/arrayManager.dart';
import 'package:nepuro/src/http/classManager.dart';
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
        final List<RouteFunc> routeDataList = RouteFuncData().getAll();
        //routeListのなかからpath,methodが一致する関数のみ取得
        final RouteFunc routeData =
            await RouteFuncData().getMatch(request, routeDataList);

        //routeが空かNullなら　404を返す
        if (routeData == null) {
          response.headers.set("Content-Type", "text/plain");
          response.statusCode = 404;
          response.write("NOT FOUND");
          response.close();

          print("status: 400");
        } else {
          //ライブラリの利用者に返すデータ
          Request returnReqData = Request(request, null, null);

          //ライブラリの利用者がvariablePathデータを要求していたら
          if (routeData.metadata.variablePath != null) {
            returnReqData.variablePath = request.uri.pathSegments.last;
          }

          //ライブラリの利用者がbodyデータを要求していたら
          if (routeData.metadata.body != null) {
            Map body;

            await _getRequestBody(request).then((requestBody) {
              body = requestBody;
            });

            //要求しているタイプ(route.metadata.body)にbodyを変換
            ClassMirror bodyType = reflectType(routeData.metadata.body);
            List<String> fieldNemeList = getFieldNames(bodyType);
            List arguments = sortFromList(fieldNemeList, body).values.toList();
            returnReqData.body = bodyType
                .newInstance(bodyType.owner.simpleName, arguments)
                .reflectee;

            //requestのbodyが正しいか
            bool isBodyCorrect = routeData.metadata.validateBody(body);
            //mapのvalueが一つでもnullが含まれているかどうか
            var hasNullMapValue =
                (Map map) => map.values.toList().contains(null);
            //ライブラリの利用者がNecessaryFieldを設定しているかどうか
            bool isEmptyNecessaryField =
                routeData.metadata.necessaryField == null;

            if (isEmptyNecessaryField &&
                    hasNullMapValue(returnReqData.body.asMap()) ||
                !isBodyCorrect && !isEmptyNecessaryField) {
              response.headers.set("Content-Type", "text/plain");
              response.statusCode = 400;
              response.close();

              print("status: 400");
            }
          }

          //routeFunc = @Routeがついていてpath,methodが一致する関数
          LibraryMirror owner = routeData.function.owner;
          var routeFunc =
              owner.invoke(routeData.function.simpleName, [returnReqData]);

          //すでにresponseが設定されていなければ(デフォルト値なら)
          if (response.statusCode == 200) {
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
