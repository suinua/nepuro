import 'dart:mirrors';
import 'dart:io';

import 'package:nepuro/src/http/metadataOperation.dart';
import 'package:nepuro/src/http/model/Route.dart';

class RouteData {
  Route metadata;
  MethodMirror response;

  RouteData(this.metadata, this.response);
}

//参考
//https://stackoverflow.com/questions/22740496/in-dart-can-you-retrieve-metadata-e-g-annotations-at-runtime-using-reflecti
List<RouteData> getRouteList() {
  List<RouteData> routeDataList = new List();
  List<AnnotationData> annotationDataList = getAnnotationList(Route);
  for (AnnotationData annotationData in annotationDataList) {
    routeDataList.add(RouteData(annotationData.metadata,annotationData.function));
  }
  return routeDataList;
}

RouteData getMatchRoute(HttpRequest request, List<RouteData> routeList) {
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

