import 'dart:mirrors';

class CallBackPathParameter {
  Map<String, dynamic> values;

  CallBackPathParameter();
  void setType(List<ParameterMirror> pathParameterTypes,
      Map<String, dynamic> pathSegments) {
    Map<String, dynamic> result = new Map();
    
    for (var pathParameterType in pathParameterTypes) {
      String parameterName = pathParameterType.metadata.first.reflectee.pathParameterName;
      Type pathType = pathParameterType.type.reflectedType;

      if (null == pathSegments[parameterName]) {
        print("Call.path(\"$parameterName\") is not exist.");
      } else {
        switch (pathType) {
          case String:
            result[parameterName] = pathSegments[parameterName].toString();
            break;
          case int:
            result[parameterName] = int.parse(pathSegments[parameterName]);
            break;
          case dynamic:
            result[parameterName] = pathSegments[parameterName];
            break;
          default:
            result[parameterName] = pathSegments[parameterName].toString();
        }
      }
    }
    values = result;
  }
}