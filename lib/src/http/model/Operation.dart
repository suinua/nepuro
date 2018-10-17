import 'dart:mirrors';

import 'package:nepuro/src/http/model/Route.dart';

class Operation {
  final path;
  final String method;
  const Operation.get(this.path) : this.method = "GET";
  const Operation.post(this.path) : this.method = "POST";
  const Operation.put(this.path) : this.method = "PUT";
  const Operation.delete(this.path) : this.method = "DELETE";
}