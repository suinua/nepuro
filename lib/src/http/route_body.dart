import 'dart:mirrors';

import 'package:nepuro/src/http/arrayManager.dart';
import 'package:nepuro/src/http/get_field.dart';

List<ParameterMirror> getBodyTypeList(MethodMirror method) {
  return method.parameters
      .where((parameter) => parameter.metadata.first.reflectee.type == "body")
      .toList();
}

ClassMirror getBodyType(MethodMirror method){
  return getBodyTypeList(method).first.type;
}

dynamic toBodyType(MethodMirror method, Map body) {
  ClassMirror bodyType = getBodyTypeList(method).first.type;
  List<String> fieldNemeList = getClassFieldNames(bodyType);
  List arguments = sortFromList(fieldNemeList, body).values.toList();

  return bodyType.newInstance(bodyType.owner.simpleName, arguments).reflectee;
}