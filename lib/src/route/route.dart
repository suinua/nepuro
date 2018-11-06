import 'dart:mirrors';
import 'dart:io';

import 'package:nepuro/src/annotation/call.dart';
import 'package:nepuro/src/call_back_data.dart';
import 'package:nepuro/src/metadata/get_method.dart';
import 'package:nepuro/src/route/route_body.dart';
import 'package:nepuro/src/metadata/get_field.dart';
import 'package:nepuro/src/annotation/required_field.dart';
import 'package:nepuro/src/annotation/path.dart';
import 'package:nepuro/src/route/route_var_path.dart';

class Route implements Path, RequiredField {
  String routePath;
  Map<String,dynamic> pathSegments;

  String httpMethod;

  Map<String, Type> requiredField;

  bool isCallBody;
  bool isCallPathVar;
  String contentType;

  MethodMirror method;

  Route(this.method)
      : this.routePath = getRoutePath(method),
        this.pathSegments = pathToSegments(getRoutePath(method)),
        this.httpMethod = getHttpMethod(method),
        this.requiredField = getRequiredField(method),
        this.isCallBody = getBodyTypeList(method).isNotEmpty,
        this.isCallPathVar = getPathVarTypeList(method).isNotEmpty,
        this.contentType = getContentType(method);

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
        callBackData.toMethodField(getMethodField(Call, method)));

    routeFunc.reflectee.send(response);
  }
}

List<Route> getRouteList() {
  List<Route> routeList = new List();
  List<MethodMirror> pathMethodList = getMethodOf(Path);
  for (MethodMirror pathMethod in pathMethodList) {
    routeList.add(Route(pathMethod));
  }
  return routeList;
}

Route getMatchRoute(HttpRequest request, List<Route> routeList) {
  _isMatchRoute(Route route) {
    if (route.pathSegments.length != request.uri.pathSegments.length) {
      return false;
    }

    //methodが一致していない
    if (request.method != route.httpMethod) {
      return false;
    }

    for (var index = 0; index < request.uri.pathSegments.length; index++) {
      if (route.pathSegments.values.toList()[index] is RegExp) {
        if (!route.pathSegments.values.toList()[index]
            .hasMatch(request.uri.pathSegments[index])) {
          return false;
        }
      } else if (route.pathSegments.values.toList()[index] != request.uri.pathSegments[index]) {
        return false;
      }
    }

    return true;
  }

  var matchRoute = routeList.where((route) => _isMatchRoute(route)).toList();
  return matchRoute.isEmpty ? null : matchRoute.first;
}
