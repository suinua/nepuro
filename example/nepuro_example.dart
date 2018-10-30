import 'package:nepuro/nepuro.dart';

class User implements BodyObject{
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
  return Response.ok(userList.where((user) => user["name"] == name).toList())..json();
}

//POST: http://localhost:8080/User
@Path.post("/User")
@RequiredField({"name": String})
addUser(@Call.body() User user) {
  userList.add(user.asMap());
  return Response.ok(userList)..json();
}

main(List<String> args) {
  Nepuro().server("127.0.0.1", 8080);
}
