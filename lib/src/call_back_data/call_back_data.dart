import 'package:nepuro/src/call_back_data/body.dart';
import 'package:nepuro/src/call_back_data/pathParameter.dart';


class CallBackData {
  CallBackBody _callBackBody = CallBackBody();

  CallBackBody get body => _callBackBody;
  void set body(value) => _callBackBody.value = value;

  CallBackPathParameter _callBackPathParameter = CallBackPathParameter();

  CallBackPathParameter get pathParameter => _callBackPathParameter;
  void set pathParaneter(value) => _callBackPathParameter.values = value;

  CallBackData();

  List toMethodField(List<Map> methodFieldList) {
    List result = new List();
    for (Map methodFiel in methodFieldList) {
      if (methodFiel["isCallAnnotationWith"]) {
        result.add(methodFiel["callDataType"] == "body"
            ? this.body.value
            : this.pathParameter.values[methodFiel["name"]]);
      } else {
        result.add(null);
      }
    }
    return result;
  }
}
