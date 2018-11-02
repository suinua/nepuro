import 'dart:mirrors';
import 'dart:io';

import 'package:nepuro/src/annotation/call.dart';
import 'package:nepuro/src/request_body.dart';
import 'package:nepuro/src/route/route_body.dart';
import 'package:nepuro/src/metadata/get_field.dart';
import 'package:nepuro/src/annotation/required_field.dart';
import 'package:nepuro/src/annotation/path.dart';
import 'package:nepuro/src/route/route_var_path.dart';

class Route implements Path, RequiredField {
  String httpPath;
  String httpMethod;

  Map<String, Type> requiredField;

  bool isCallBody;
  bool isCallVarPath;
  String contentType;

  MethodMirror method;

  Route(this.method)
      : this.httpMethod = getHttpMethod(method),
        this.httpPath = getHttpPath(method),
        this.contentType = getContentType(method),
        this.requiredField = getRequiredField(method),
        this.isCallBody = getBodyTypeList(method).isNotEmpty,
        this.isCallVarPath = getVarPathTypeList(method).isNotEmpty;

  bool isCorrectBody(Map requestBody) {
    bool result = true;

    //requestBodyのほうがnecessaryFieldより短いのならば
    //requestBoydは正しくない
    if (requestBody.length < requiredField.length) {
      result = false;
    } else {
      requiredField.forEach((key, type) {
        if (!(requestBody.containsKey(key) &&
            requestBody[key].runtimeType == type)) {
          result = false;
        }
      });
      getClassField(getBodyType(method)).forEach((fieldName, fieldType) {
        if (!(requestBody[fieldName].runtimeType == fieldType) &&
            requestBody[fieldName] != null) {
          result = false;
        }
      });
    }
    return result;
  }

  sendResponse(CallBackData callBackData, HttpResponse response) {
    LibraryMirror owner = method.owner;
    var routeFunc = owner.invoke(method.simpleName,
        callBackData.toMethodField(getMethodFieldNames(Call,method)));

    routeFunc.reflectee.send(response);
  }
}

List<Route> getRouteList() {
  List<Route> routeList = new List();
  List<MethodMirror> pathMethodList = getPathMethodList();
  for (MethodMirror pathMethod in pathMethodList) {
    routeList.add(Route(pathMethod));
  }
  return routeList;
}

Route getMatchRoute(HttpRequest request, List<Route> routeList) {
  _isMatchRoute(Route route) {
    //methodが一致していれば
    if (request.method == route.httpMethod) {
      //variablePathが無い && パスが完全一致する
      if (!route.isCallVarPath && route.httpPath == request.uri.path) {
        return true;
      }

      //variablePathがあり &&　正規表現と一致する
      if (RegExp("\^${route.httpPath}/.((?!/).)*\$")
              .hasMatch(request.uri.path) &&
          route.isCallVarPath) {
        return true;
      }
    }

    return false;
  }

  var matchRoute = routeList.where((route) => _isMatchRoute(route)).toList();
  return matchRoute.isEmpty ? null : matchRoute.first;
}