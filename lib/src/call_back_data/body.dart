import 'dart:convert';
import 'dart:mirrors';

import 'package:nepuro/src/metadata/get_field.dart';
import 'package:nepuro/src/route/route_body.dart';

class CallBackBody {
  dynamic value;

  CallBackBody();
  Future<bool> transform(String contentType) async {
    bool isSuccess = true;
    try {
      switch (contentType) {
        case "text/plain":
          this.value = await this.value.transform(utf8.decoder).join();
          break;

        case "application/json":
          var content = await this.value.transform(utf8.decoder).join();
          this.value = jsonDecode(content) as Map;
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

  setType(MethodMirror method) {
    ClassMirror bodyType = getBodyTypeList(method).first.type;
    List<String> fieldNemeList = getClassFieldNames(bodyType);

    Map _sortFromList(List keyList, Map map) {
      Map result = new Map();
      for (String key in keyList) {
        result[key] = map[key];
      }
      return result;
    }

    List arguments = _sortFromList(fieldNemeList, this.value).values.toList();

    this.value =
        bodyType.newInstance(bodyType.owner.simpleName, arguments).reflectee;
  }
}