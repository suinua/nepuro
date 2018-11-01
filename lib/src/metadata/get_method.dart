import 'dart:mirrors';

//参考
//https://stackoverflow.com/questions/22740496/in-dart-can-you-retrieve-metadata-e-g-annotations-at-runtime-using-reflecti
List<MethodMirror> getMethodOf(Type annotation) {
  List<MethodMirror> methodList = new List();
  ClassMirror annotationType = reflectType(annotation);

  MirrorSystem ms = currentMirrorSystem();
  ms.libraries.forEach((u, lm) {
    lm.declarations.forEach((s, method) {
      method.metadata.forEach((metadata) {
        if (metadata.type == annotationType) {
          methodList.add(method);
        }
      });
    });
  });
  return methodList;
}
