import 'dart:mirrors';

import 'package:nepuro/src/route/route.dart';

Map<String,dynamic> getPathVarList(List requestPathSegment, Route route) {
  Map<String,dynamic> result = new Map();
  for (var index = 0; index < route.pathSegments.keys.length; index++) {
    if (route.pathSegments.keys.toList()[index] != "normal"){
      result[route.pathSegments.keys.toList()[index]] = requestPathSegment[index];
    }
  }
  return result;
}

List<ParameterMirror> getPathVarTypeList(MethodMirror method) {
  return method.parameters
      .where((parameter) => parameter.metadata.first.reflectee.type == "path")
      .toList();
}

dynamic getPathVar(MethodMirror method, dynamic path) {
  Type pathType = getPathVarTypeList(method).first.type.reflectedType;
  switch (pathType) {
    case String:
      return path.toString();
      break;
    case int:
      return int.parse(path);
      break;
    default:
      //例外処理で「Stringかintのみ対応しています」
      return path;
  }
}
