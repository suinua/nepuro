import 'dart:io';

class Call {
  final String type;
  
  const Call.path():this.type = "path";
  const Call.body():this.type = "body";
}