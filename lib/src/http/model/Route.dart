import 'dart:mirrors';

import 'package:nepuro/src/http/model/Operation.dart';


class Route {
  String path;
  String method;
  MethodMirror responseFunc;
  
  Route(this.path,this.method,this.responseFunc);
}


//参考
//https://stackoverflow.com/questions/22740496/in-dart-can-you-retrieve-metadata-e-g-annotations-at-runtime-using-reflecti
List getRoutes() {
  List res = new List();
  MirrorSystem ms = currentMirrorSystem();
  ms.libraries.forEach((u, lm) {
    lm.declarations.forEach((s, dm) {
      dm.metadata.forEach((im) {
        if ((im.reflectee is Operation)) {
          res.add(Route(im.reflectee.path, im.reflectee.method,dm));
        }
      });
    });
  });
  return res;
}