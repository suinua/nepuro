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

String getRoutePath(MethodMirror method) {
  String routePath;
  method.metadata.forEach((metadata) {
    if (metadata.type.reflectedType == Path) {
      routePath = metadata.reflectee.routePath;
    }
  });
  return routePath;
}

String getHttpMethod(MethodMirror method) {
  String httpMethod;
  method.metadata.forEach((metadata) {
    if (metadata.type.reflectedType == Path) {
      httpMethod = metadata.reflectee.httpMethod;
    }
  });
  return httpMethod;
}

Map<String,dynamic> pathToSegments(String path) {
  List<dynamic> tempPathSegments = path.replaceFirst("/", "").split("/");
  Map<String,dynamic> pathSegments = new Map();
  for (var index = 0; index < tempPathSegments.length; index++) {
    //正規表現
    if (RegExp(r"r\[(.*)\:(.*)\]").hasMatch(tempPathSegments[index])) {
      //パス変数名 : 正規表現
      pathSegments[tempPathSegments[index]
              .replaceAll(RegExp(r"r\[(.*):"), "")
              .replaceAll("]", "")] =
          RegExp(tempPathSegments[index]
              .replaceAll("r[", "")
              .replaceAll(RegExp(r":(.*)\]"), ""));

    //パス変数
    } else if (RegExp(r"\[\:(.*)\]").hasMatch(tempPathSegments[index])) {
      //パス変数名 : 正規表現
      pathSegments[tempPathSegments[index]
              .replaceAll("\[\:", "")
              .replaceAll("]", "")] = (RegExp("(.*)"));

      //ただのパス
    } else {
      pathSegments["normal $index"] = tempPathSegments[index];
    }
  }
  return pathSegments;
}

bool isContainsPathVar(String routePath) {
  return RegExp("\[\:(.*)\]").hasMatch(routePath);
}
