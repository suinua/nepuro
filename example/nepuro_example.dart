import 'package:nepuro/nepuro.dart';

class User {
  String name;
  int age;
  User(this.name, this.age);

  Map asMap() => {"name": this.name, "age": this.age};
}

//GET: http://localhost:8080/User
@Route.post("/hello",body: "text/plain")
hrllo(Request request) {
  return Response.ok(request.body)..text();
}

List userList = new List();

//GET: http://localhost:8080/User
@Route.get("/User")
getUser(Request request) {
  return Response.ok(userList)..json();
}

//GET: http://localhost:8080/User/suinua
@Route.get("/User", variablePath: "userName")
findUser(Request request) {
  var userName = request.variablePath;
  return Response.ok(
      userList.where((user) => user["name"] == userName).toList())
    ..json();
}

//POST: http://localhost:8080/User
@Route.post("/User", body: User)
addUser(Request request) {
  User userData = request.body;
  userList.add(userData.asMap());
  return Response.ok(userList)..json();
}

//POT: http://localhost:8080/User
@Route.put("/User", body: User, necessaryField: {"name": String})
updateUser(Request request) {
  User userData = request.body;

  for (var user in userList) {
    if (user["name"] == userData.name) {
      user["name"] = userData.name ?? user["name"];
      user["age"] = userData.age ?? user["age"];
    }
  }

  return Response.ok(userList)..json();
}

//DELETE: http://localhost:8080/User
@Route.delete("/User", variablePath: "userName")
deleteUser(Request request) {
  var userName = request.variablePath;
  userList.removeWhere((user) => user["name"] == userName);
  return Response.ok(userList)..json();
}

main() {
  Nepuro().server("127.0.0.1", 8080);
}
