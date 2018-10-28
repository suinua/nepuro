import 'dart:io';

class Request {
  final String type;
  
  const Request.path():this.type = "path";
  const Request.body():this.type = "body";
}