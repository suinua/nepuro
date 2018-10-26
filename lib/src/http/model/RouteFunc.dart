import 'dart:mirrors';
import 'dart:io';

import 'package:nepuro/src/http/model/AnnotatedFunc.dart';
import 'package:nepuro/src/http/model/Route.dart';
class RouteFunc {
  Route metadata;
  MethodMirror function;

  RouteFunc(this.metadata, this.function);
}

class RouteFuncData {
  List<RouteFunc> getAll() {
    List<RouteFunc> routeDataList = new List();
    List<AnnotatedFunc> annotationDataList = AnnotatedFuncData().getOf(Route);
    for (AnnotatedFunc annotationData in annotationDataList) {
      routeDataList
          .add(RouteFunc(annotationData.metadata, annotationData.function));
    }
    return routeDataList;
  }

  RouteFunc getMatch(HttpRequest request, List<RouteFunc> routeList) {
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
}
