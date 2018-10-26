import 'dart:mirrors';

List<String> getFieldNames(ClassMirror type) {
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
