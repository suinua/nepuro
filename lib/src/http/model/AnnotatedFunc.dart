import 'dart:mirrors';

class AnnotatedFunc {
  dynamic metadata;
  MethodMirror function;

  AnnotatedFunc(this.metadata, this.function);
}

//クラスを作る必要があるのかわからないけど。。
class AnnotatedFuncData {
  //参考
  //https://stackoverflow.com/questions/22740496/in-dart-can-you-retrieve-metadata-e-g-annotations-at-runtime-using-reflecti
  List<AnnotatedFunc> getOf(Type annotation) {
    List<AnnotatedFunc> annotationDataList = new List();
    ClassMirror annotationType = reflectType(annotation);

    MirrorSystem ms = currentMirrorSystem();
    ms.libraries.forEach((u, lm) {
      lm.declarations.forEach((s, function) {
        function.metadata.forEach((metadata) {
          if (metadata.type == annotationType) {
            AnnotatedFunc annotationData =
                AnnotatedFunc(metadata.reflectee, function);
            annotationDataList.add(annotationData);
          }
        });
      });
    });
    return annotationDataList;
  }
}