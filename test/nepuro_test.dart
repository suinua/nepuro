import 'dart:convert';

import 'package:nepuro/nepuro.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

@BodyObject()
class User {
  String name;
  int age;
  User(this.name, this.age);

  Map asMap() => {"name": this.name, "age": this.age};
}

List<Map> userList = new List();

@Path.get("/User")
getAllUser() {
  return Response.ok(userList)..json();
}

@Path.get("/User")
getUser(@Call.path() String name) {
  return Response.ok(userList.where((user) => user["name"] == name).toList())
    ..json();
}

@Path.post("/User")
@RequiredField({"name": String})
addUser(@Call.body() User user) {
  userList.add(user.asMap());
  return Response.ok(userList)..json();
}

void main() {
  Nepuro().server();

  group("normal:", () {
    
    test("get", () async {
      var body;
      await http.get("http://localhost:8080/User").then((response) {
        body = jsonDecode(response.body);
      });
      expect(body, []);
    });

    test("post", () async {
      var body;
      await http
          .post("http://localhost:8080/User",
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({"name": "hello", "age": 10}))
          .then((response) {
        body = jsonDecode(response.body);
      });
      expect(body.asMap(), [{"name": "hello", "age": 10}]);
    });

  });
}
