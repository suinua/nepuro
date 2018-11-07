import 'dart:mirrors';

Map<String, dynamic> getPathParameter(
    Map<String, dynamic> pathSegments, List requestPathSegment) {
  Map<String, dynamic> result = new Map();
  for (var index = 0; index < pathSegments.keys.length; index++) {
    if (!RegExp(r"normal").hasMatch(pathSegments.keys.toList()[index])) {
      result[pathSegments.keys.toList()[index]] = requestPathSegment[index];
    }
  }
  return result;
}

List<ParameterMirror> getPathParameterTypes(MethodMirror method) {
  return method.parameters
      .where((parameter) => parameter.metadata.first.reflectee.type == "path")
      .toList();
}
