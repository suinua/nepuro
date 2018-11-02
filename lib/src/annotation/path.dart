import 'dart:mirrors';

import 'package:nepuro/src/metadata/get_method.dart';

class Path {
  final String routePath;
  final String httpMethod;

  const Path.get(this.routePath) : this.httpMethod = "GET";

  const Path.post(this.routePath) : this.httpMethod = "POST";

  const Path.put(this.routePath) : this.httpMethod = "PUT";

  const Path.delete(this.routePath) : this.httpMethod = "DELETE";
}

List<MethodMirror> getPathMethodList() {
  List<MethodMirror> pathMethodList = new List();
  List<MethodMirror> annotationDataList = getMethodOf(Path);
  for (MethodMirror method in annotationDataList) {
    pathMethodList.add(method);
  }
  return pathMethodList;
}

String getRoutePath(MethodMirror method){
  String routePath;
  method.metadata.forEach((metadata){
    if(metadata.type.reflectedType == Path){
      routePath = metadata.reflectee.routePath;
    }
  });
  return routePath;
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