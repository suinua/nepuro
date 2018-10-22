import 'dart:io';

class Request {
  HttpRequest httpRequest;

  dynamic variablePath;
  dynamic body;

  Request(this.httpRequest,this.variablePath,this.body);
}