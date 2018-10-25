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
        print("[${request.method}] ${request.uri.path}");

        HttpResponse response = request.response;

        //@Routeのつく関数をすべて取得しpath,methodが一致する関数のみ取得
        final _RouteData route = await _getMatchRoute(request, _getRouteList());

        //routeが空かNullなら　404を返す
        if (route == null) {
          response.headers.set("Content-Type", "text/plain");
          response.statusCode = 404;
          response.write("NOT FOUND");
          response.close();

          print("status: 400");
        } else {
          //ライブラリの利用者に返すデータ
          Request returnReqData = Request(request, null, null);

          //ライブラリの利用者がvariablePathデータを要求していたら
          if (route.metadata.variablePath != null) {
            returnReqData.variablePath = request.uri.pathSegments.last;
          }

          //ライブラリの利用者がbodyデータを要求していたら
          if (route.metadata.body != null) {
            await _getBody(request).then((body) {
              //要求しているタイプ(route.metadata.body)にbodyを変換
              ClassMirror bodyType = reflectType(route.metadata.body);
              List<String> fieldNemeList = _getFieldNameList(bodyType);
              List arguments =
                  _sortFromList(fieldNemeList, body).values.toList();
              returnReqData.body = bodyType
                  .newInstance(bodyType.owner.simpleName, arguments)
                  .reflectee;

              //requestのbodyが正しいか
              bool isBodyCorrect = route.metadata.validateBody(body);
              //mapのvalueが一つでもnullが含まれているかどうか
              var hasNullMapValue =
                  (Map map) => map.values.toList().contains(null);
              //ライブラリの利用者がNecessaryFieldを設定しているかどうか
              bool isEmptyNecessaryField =
                  route.metadata.necessaryField == null;

              if (isEmptyNecessaryField &&
                      hasNullMapValue(returnReqData.body.asMap()) ||
                  !isBodyCorrect && !isEmptyNecessaryField) {
                response.headers.set("Content-Type", "text/plain");
                response.statusCode = 400;
                response.close();

                print("status: 400");
              }
            });
          }

          //responseFunc = @Routeがついていてpath,methodが一致する関数
          LibraryMirror owner = route.response.owner;
          var responseFunc =
              owner.invoke(route.response.simpleName, [returnReqData]);

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
  List<_RouteData> _getRouteList() {
    List<_RouteData> routes = new List();
    MirrorSystem ms = currentMirrorSystem();
    ms.libraries.forEach((u, lm) {
      lm.declarations.forEach((s, func) {
        func.metadata.forEach((im) {
          if ((im.reflectee is Route)) {
            _RouteData routeData = _RouteData(im.reflectee, func);
            routes.add(routeData);
          }
        });
      });
    });
    return routes;
  }

  _RouteData _getMatchRoute(HttpRequest request, List<_RouteData> routeList) {
    var isVarEmpty = (variable) => variable == null;
    var isVarNotEmpty = (variable) => variable != null;

    _isMatchRoute(route) {
      //methodが一致していれば
      if (request.method == route.metadata.method) {

        //variablePathが無い && パスが完全一致する
        if (isVarEmpty(route.metadata.variablePath) &&
            route.metadata.path == request.uri.path) {
          return true;
        }

        //variablePathがあり &&　正規表現と一致する
        if (RegExp("\^${route.metadata.path}/.((?!/).)*\$")
                .hasMatch(request.uri.path) &&
            isVarNotEmpty(route.metadata.variablePath)) {
          return true;
        }
      }

      return false;
    }

    var matchRoute = routeList.where((route) => _isMatchRoute(route)).toList();
    return matchRoute.isEmpty ? null : matchRoute.first;
  }

  Future _getBody(HttpRequest request) async {
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

List<String> _getFieldNameList(ClassMirror type) {
  List<String> fieldNameList = new List();

  type.declarations.forEach((key, value) {
    if (value is VariableMirror) {
      fieldNameList.add(value
          .toString()
          .replaceAll("VariableMirror on ", "")
          .replaceAll("\'", ""));
    }
  });

  return fieldNameList;
}

Map _sortFromList(List keyList, Map map) {
  Map result = new Map();
  for (String key in keyList) {
    result[key] = map[key];
  }
  return result;
}

class _RouteData {
  Route metadata;
  MethodMirror response;

  _RouteData(this.metadata, this.response);
}
