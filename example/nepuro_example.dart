import 'package:nepuro/nepuro.dart';

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

//GET: http://localhost:8080/User
@Path.get("/User")
getAllUser() {
  return Response.ok(userList)..json();
}

//GET: http://localhost:8080/User/[:name]
@Path.get("/User")
getUser(@Call.path() String name) {
  print(name);
  return Response.ok(userList.where((user) => user["name"] == name).toList())
    ..json();
}

//POST: http://localhost:8080/User
@Path.post("/User")
@RequiredField({"name": String, "age": int})
addUser(@Call.body() User user) {
  user.id = userList[userList.length - 1]["id"] + 1;
  userList.add(user.asMap());
  return Response.ok(userList)..json();
}

//PUT: http://localhost:8080/User
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

main(List<String> args) {
  Nepuro().server();
}
