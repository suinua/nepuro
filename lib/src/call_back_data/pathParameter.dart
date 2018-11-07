import 'dart:mirrors';

class CallBackPathParameter {
  Map<String, dynamic> values;

  CallBackPathParameter();
  void setType(List<ParameterMirror> pathParameterTypes,
      Map<String, dynamic> pathSegments) {
    Map<String, dynamic> result = new Map();
    
    for (var pathVarType in pathParameterTypes) {
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
    values = result;
  }
}