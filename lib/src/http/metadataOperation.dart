import 'dart:mirrors';

class AnnotationData {
  dynamic metadata;
  MethodMirror function;

  AnnotationData(this.metadata, this.function);
}

List<String> getFieldNameList(ClassMirror type) {
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

List<AnnotationData> getAnnotationList(Type annotation) {
  List<AnnotationData> annotationDataList = new List();
  ClassMirror annotationType = reflectType(annotation);

  MirrorSystem ms = currentMirrorSystem();
  ms.libraries.forEach((u, lm) {
    lm.declarations.forEach((s, func) {
      func.metadata.forEach((im) {
        if (im.type == annotationType) {
          AnnotationData annotationData = AnnotationData(im.reflectee, func);
          annotationDataList.add(annotationData);
        }
      });
    });
  });
  return annotationDataList;
}
