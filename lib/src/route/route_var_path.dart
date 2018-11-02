import 'dart:mirrors';

List<ParameterMirror> getVarPathTypeList(MethodMirror method) {
  return method.parameters
      .where((parameter) => parameter.metadata.first.reflectee.type == "path")
      .toList();
}

dynamic toVarPathType(MethodMirror method, dynamic path) {
  Type pathType = getVarPathTypeList(method).first.type.reflectedType;
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