import 'package:nepuro/nepuro.dart';

class User {
  String name;
  int age;
  User(this.name, this.age);

  Map asMap() => {"name": this.name, "age": this.age};
}

List userList = new List();

//GET: http://localhost:8080/User
@Route.get("/User")
getUser(Request request) {
  return Response(userList, 200)..json();
}

//GET: http://localhost:8080/User/suinua
@Route.get("/User", variablePath: "userName")
findUser(Request request) {
  var userName = request.variablePath;
  return Response(
      userList.where((user) => user["name"] == userName).toList(), 200)
    ..json();
}

//POST: http://localhost:8080/User
@Route.post("/User", body: User)
addUser(Request request) {
  User userData = request.body;
  userList.add(userData.asMap());
  return Response(userList, 200)..json();
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

  return Response(userList, 200)..json();
}

//DELETE: http://localhost:8080/User
@Route.delete("/User", variablePath: "userName")
deleteUser(Request request) {
  var userName = request.variablePath;
  userList.removeWhere((user) => user["name"] == userName);
  return Response(userList, 200)..json();
}

main() {
  Nepuro().server("127.0.0.1", 8080);
}
