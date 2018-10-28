import 'package:nepuro/nepuro.dart';

class User {
  String name;
  int age;
  User(this.name, this.age);

  Map asMap() => {"name": this.name, "age": this.age};
}

List<Map> userList = new List();

@Route.get("/User")
getAllUser() {
  return Response.ok(userList)..json();
}

@Route.get("/User")
getUser(@Request.path() String name) {
  return Response.ok(userList.where((user) => user["name"] == name).toList())..json();
}

//POST: http://localhost:8080/User
@Route.post("/User")
@NecessaryField({"name": String})
addUser(@Request.body() User user) {
  userList.add(user.asMap());
  return Response.ok(userList)..json();
}

main(List<String> args) {
  Nepuro().server("127.0.0.1", 8080);
}
