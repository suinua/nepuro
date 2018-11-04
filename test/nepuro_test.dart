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

@Path.get("/User")
getAllUser() {
  return Response.ok(userList)..json();
}

@Path.get("/User/[:name]")
getUser(@Call.path("name") String name) {
  return Response.ok(userList.where((user) => user["name"] == name).toList())
    ..json();
}

@Path.post("/User")
@RequiredField({"name": String, "age": int})
addUser(@Call.body() User user) {
  //userListの一番うしろのuserのid + 1
  user.id = userList[userList.length - 1]["id"] + 1;
  userList.add(user.asMap());
  return Response.ok(userList)..json();
}

@Path.put("/User")
@RequiredField({"id": int})
updateUser(@Call.body() User user) {
  for (int index = 0; index < userList.length; index++) {
    if (userList[index]["id"] == user.id) {
      userList[index]["name"] = user.name ?? userList[index]["name"];
      userList[index]["age"] = user.age ?? userList[index]["age"];
    }
  }

  return Response.ok(userList)..json();
}

void main() {
  Nepuro().server();

  group("normal", () {
    test("get", () async {
      var body;
      await http.get("http://localhost:8080/User").then((response) {
        body = jsonDecode(response.body);
      });
      expect(body, [
        {"id": 1, "name": "Yuuta", "age": 12},
        {"id": 2, "name": "Kenta", "age": 16}
      ]);
    });

    test("get name == kenta", () async {
      var body;
      await http.get("http://localhost:8080/User/Kenta").then((response) {
        body = jsonDecode(response.body);
      });
      expect(body, [
        {'id': 2, 'name': 'Kenta', 'age': 16},
      ]);
    });

    test("post", () async {
      var body;
      await http
          .post("http://localhost:8080/User",
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({"name": "Sinji", "age": 14}))
          .then((response) {
        body = jsonDecode(response.body);
      });
      expect(body, [
        {'id': 1, 'name': 'Yuuta', 'age': 12},
        {'id': 2, 'name': 'Kenta', 'age': 16},
        {'id': 3, 'name': 'Sinji', 'age': 14}
      ]);
    });

    test("put", () async {
      var body;
      await http
          .put("http://localhost:8080/User",
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({"id": 3, "age": 16}))
          .then((response) {
        body = jsonDecode(response.body);
      });
      expect(body, [
        {'id': 1, 'name': 'Yuuta', 'age': 12},
        {'id': 2, 'name': 'Kenta', 'age': 16},
        {'id': 3, 'name': 'Sinji', 'age': 16}
      ]);
    });
  });
}
