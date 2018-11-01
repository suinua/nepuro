import 'dart:mirrors';

class RequiredField {
  final Map<String, Type> requiredField;
  const RequiredField(this.requiredField);
}

List<RequiredField> getRequiredFieldList(MethodMirror method) {
  List<InstanceMirror> mockNecessaryFieldList = method.metadata
      .where((metadata) => metadata.reflectee.runtimeType == RequiredField)
      .toList();

  List<RequiredField> necessaryFieldList = new List();
  mockNecessaryFieldList.forEach((necessaryField) {
    necessaryFieldList.add(necessaryField.reflectee);
  });
  return necessaryFieldList;
}

Map<String,Type> getRequiredField(MethodMirror method){
  return getRequiredFieldList(method).isEmpty ? {} : getRequiredFieldList(method).first.requiredField;
}