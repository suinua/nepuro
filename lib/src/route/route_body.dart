import 'dart:mirrors';

List<ParameterMirror> getBodyTypeList(MethodMirror method) {
  return method.parameters
      .where((parameter) => parameter.metadata.first.reflectee.type == "body")
      .toList();
}

ClassMirror getBodyType(MethodMirror method) {
  return getBodyTypeList(method).first.type;
}

String getContentType(MethodMirror method) {
  String contenType;
  method.parameters.forEach((parameter){
    contenType = parameter.metadata.first.reflectee.contentType;
  });
  return contenType;
}
