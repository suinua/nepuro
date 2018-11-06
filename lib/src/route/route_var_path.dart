import 'dart:mirrors';

Map<String, dynamic> getPathVarValues(
    Map<String, dynamic> pathSegments, List requestPathSegment) {
  Map<String, dynamic> result = new Map();
  for (var index = 0; index < pathSegments.keys.length; index++) {
    if (!RegExp(r"normal").hasMatch(pathSegments.keys.toList()[index])) {
      result[pathSegments.keys.toList()[index]] = requestPathSegment[index];
    }
  }
  return result;
}

List<ParameterMirror> getPathVarTypeList(MethodMirror method) {
  return method.parameters
      .where((parameter) => parameter.metadata.first.reflectee.type == "path")
      .toList();
}

Map<String, dynamic> toPathVarType(
    MethodMirror method, Map<String, dynamic> pathSegments) {
  Map<String, dynamic> result = new Map();
  for (var pathVarType in getPathVarTypeList(method)) {
    String pathVarName = pathVarType.metadata.first.reflectee.pathVarName;
    Type pathType = pathVarType.type.reflectedType;

    if (null == pathSegments[pathVarName]) {
      print("Call.path(\"$pathVarName\") is not exist.");
    } else {
      switch (pathType) {
        case String:
          result[pathVarName] = pathSegments[pathVarName].toString();
          break;
        case int:
          result[pathVarName] = int.parse(pathSegments[pathVarName]);
          break;
        case dynamic:
          result[pathVarName] = pathSegments[pathVarName];
          break;
        default:
          result[pathVarName] = pathSegments[pathVarName].toString();
      }
    }
  }
  return result;
}
