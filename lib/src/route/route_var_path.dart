import 'dart:mirrors';

import 'package:nepuro/src/route/route.dart';

Map<String, dynamic> getPathVarList(List requestPathSegment, Route route) {
  Map<String, dynamic> result = new Map();
  for (var index = 0; index < route.pathSegments.keys.length; index++) {
    if (!RegExp(r"normal").hasMatch(route.pathSegments.keys.toList()[index])) {
      result[route.pathSegments.keys.toList()[index]] =
          requestPathSegment[index];
    }
  }
  return result;
}

List<ParameterMirror> getPathVarTypeList(MethodMirror method) {
  return method.parameters
      .where((parameter) => parameter.metadata.first.reflectee.type == "path")
      .toList();
}

Future<Map<String, dynamic>> toPathVarType(MethodMirror method, Map<String, dynamic> pathSegments) async {
  Map<String, dynamic> result = new Map();
  for (var pathVarType in getPathVarTypeList(method)) {
    String pathVarName = pathVarType.metadata.first.reflectee.pathVarName;
    Type pathType = pathVarType.type.reflectedType;
    switch (pathType) {
      case String:
        result[pathVarName] = pathSegments[pathVarName].toString();
        break;
      case int:
        result[pathVarName] = int.parse(pathSegments[pathVarName]);
        break;
      default:
        //例外処理で「Stringかintのみ対応しています」
        return result;
    }
  }
  return result;
}
