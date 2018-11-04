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

@Path.get("/User/r[/d:id]/name")
getName(@Call.path("id") int id) {
  return Response.ok(userList.where((user) => user["name"] == id).first["name"])..json();
}

void main() {
  Nepuro().server();

  group("path test", () {
    test("get name", () async {
      var body;
      await http.get("http://localhost:8080/User/1/name").then((response) {
        body = jsonDecode(response.body);
      });
      expect(body, [
        "Yuuta"
      ]);
    });

  });
}
