Map asMap(List keyList, List valueList){
  Map result = new Map();
  for (var index = 0; index < keyList.length; index++) {
    result[keyList[index]] = valueList[index];
  }
  return result;
}

Map sortFromList(List keyList, Map map) {
  Map result = new Map();
  for (String key in keyList) {
    result[key] = map[key];
  }
  return result;
}

List requDataToFuncField(List<Map> fieldList, Map returnReqData){
  List result = new List();
  for (Map field in fieldList) {
    if (field["isRequest"]) {
      result.add(field["requestType"] == "body" ? returnReqData["body"] : returnReqData["path"]);
    } else {
      result.add(null);
    }
  }
  return result;
}