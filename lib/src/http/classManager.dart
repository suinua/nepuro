import 'dart:mirrors';

import 'package:nepuro/src/http/model/Request.dart';

List<Map> getMethodFieldNames(MethodMirror method){
  List<Map> fieldNameList = new List();

  method.parameters.forEach((parameter) {
      var name = parameter
          .toString()
          .replaceAll("ParameterMirror on ", "")
          .replaceAll("\'", "");
      bool isRequest = parameter.metadata.isEmpty ? false : parameter.metadata.first.reflectee.runtimeType == Request;
      String requestType = isRequest ? parameter.metadata.first.reflectee.type : null;
      fieldNameList.add({"name":name,"isRequest":isRequest,"requestType":requestType});
  });

  return fieldNameList;
}

List<String> getClassFieldNames(ClassMirror type) {
  List<String> fieldNameList = new List();

  type.declarations.forEach((key, value) {
    if (value is VariableMirror) {
      fieldNameList.add(value
          .toString()
          .replaceAll("VariableMirror on ", "")
          .replaceAll("\'", ""));
    }
  });

  return fieldNameList;
}

