import 'dart:convert';

import 'package:nepuro/nepuro.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

@BodyObject()
class User {
  int id;
  String name;
  int age;
  User(this.id, this.name, this.age);

  Map asMap() => {"id": this.id, "name": this.name, "age": this.age};
}

List<Map> userList = [
  {"id": 1, "name": "Yuuta", "age": 12},
  {"id": 2, "name": "Kenta", "age": 16}
];

@Path.get(r"/User/r[\d:id]/[:parameter]")
getName(@Call.path("id") int userId,@Call.path("lenght") int height) {
  print(userId);
  print(height);
  return Response.ok(userList.where((user) => user["id"] == userId))
    ..text();
}

void main() {
  Nepuro().server();

  group("path test", () {
    test("get name", () async {
      var body;
      await http.get("http://localhost:8080/User/1/name/5").then((response) {
        body = response.body;
      });
      print(body);
    });
  });
}
