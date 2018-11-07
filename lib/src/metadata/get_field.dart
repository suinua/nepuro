import 'dart:mirrors';


List<Map> getMethodField(Type type,MethodMirror method){
  List<Map> fieldList = new List();

  method.parameters.forEach((parameter) {
      var name = parameter.metadata.first.reflectee.pathParameterName;
      bool isCallAnnotationWith = parameter.metadata.isEmpty ? false : parameter.metadata.first.reflectee.runtimeType == type;
      String callDataType = isCallAnnotationWith ? parameter.metadata.first.reflectee.type : null;
      fieldList.add({"name":name,"isCallAnnotationWith":isCallAnnotationWith,"callDataType":callDataType});
  });
  return fieldList;
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

Map<String,Type> getClassField(ClassMirror type) {
  Map<String,Type> fieldList = new Map();

  type.declarations.forEach((key, value) {
    if (value is VariableMirror) {
     String fieldName = value
          .toString()
          .replaceAll("VariableMirror on ", "")
          .replaceAll("\'", "");
      fieldList[fieldName] = value.type.reflectedType;
    }
  });

  return fieldList;
}