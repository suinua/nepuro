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