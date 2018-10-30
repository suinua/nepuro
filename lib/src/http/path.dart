import 'dart:io';
import 'dart:mirrors';

import 'package:nepuro/src/http/get_method.dart';

class Path {
  final String httpPath;
  final String httpMethod;

  const Path.get(this.httpPath) : this.httpMethod = "GET";

  const Path.post(this.httpPath) : this.httpMethod = "POST";

  const Path.put(this.httpPath) : this.httpMethod = "PUT";

  const Path.delete(this.httpPath) : this.httpMethod = "DELETE";
}

List<MethodMirror> getPathMethodList() {
  List<MethodMirror> pathMethodList = new List();
  List<MethodMirror> annotationDataList = getMethodOf(Path);
  for (MethodMirror method in annotationDataList) {
    pathMethodList.add(method);
  }
  return pathMethodList;
}

String getHttpPath(MethodMirror method){
  String httpPath;
  method.metadata.forEach((metadata){
    if(metadata.type.reflectedType == Path){
      httpPath = metadata.reflectee.httpPath;
    }
  });
  return httpPath;
}

String getHttpMethod(MethodMirror method){
  String httpMethod;
  method.metadata.forEach((metadata){
    if(metadata.type.reflectedType == Path){
      httpMethod = metadata.reflectee.httpMethod;
    }
  });
  return httpMethod;
}