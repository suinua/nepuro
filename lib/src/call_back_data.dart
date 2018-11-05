import 'dart:convert';
import 'dart:mirrors';

import 'package:nepuro/src/metadata/get_field.dart';
import 'package:nepuro/src/route/route_body.dart';

class CallBackData {
  dynamic body;
  Map<String, dynamic> pathVarValues;

  CallBackData({this.body, this.pathVarValues});
  setPathVarValues(){
  }
  Future<bool> bodyParse(contentType) async {
    bool isSuccess = true;
    try {
      switch (contentType) {
        case "text/plain":
          this.body = await this.body.transform(utf8.decoder).join();
          break;

        case "application/json":
          var content = await this.body.transform(utf8.decoder).join();
          this.body = jsonDecode(content) as Map;
          break;
        default:
          isSuccess = false;
          break;
      }
    } catch (e) {
      isSuccess = false;
    }
    return isSuccess;
  }

  toSetBodyType(MethodMirror method) {
    ClassMirror bodyType = getBodyTypeList(method).first.type;
    List<String> fieldNemeList = getClassFieldNames(bodyType);
    List arguments = _sortFromList(fieldNemeList, this.body).values.toList();

    this.body =
        bodyType.newInstance(bodyType.owner.simpleName, arguments).reflectee;
  }

  List toMethodField(List<Map> methodFieldList) {
    List result = new List();
    for (Map methodFiel in methodFieldList) {
      if (methodFiel["isCallAnnotationWith"]) {
        result.add(methodFiel["callDataType"] == "body"
            ? this.body
            : this.pathVarValues[methodFiel["name"]]);
      } else {
        result.add(null);
      }
    }
    return result;
  }
}

Map _sortFromList(List keyList, Map map) {
  Map result = new Map();
  for (String key in keyList) {
    result[key] = map[key];
  }
  return result;
}
