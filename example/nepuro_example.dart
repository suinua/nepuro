import 'package:nepuro/nepuro.dart';

//GET: http://localhost:8080/User
// >> get user
@Route.get("/User")
getUser(Request request) {
  return Response("get user", 200)..text();
}

//GET: http://localhost:8080/User/suinua
// >> find user, userName:suinua
@Route.get("/User", variablePath: "userName")
findUser(Request request) {
  var userName = request.variablePath;
  return Response("find user, userName:${userName}", 200)..text();
}

//POST: http://localhost:8080/User
// >> add user userData:{name: name, age: 1}
@Route.post("/User", body:{"name":String,"age":int})
addUser(Request request) {
  var userData = request.body;
  return Response("add user userData:${userData}", 200)..text();
}

//DELETE: http://localhost:8080/User
// >> delet user userName:suinua
@Route.delete("/User", variablePath: "userName")
deleteUser(Request request) {
  var userName = request.variablePath;
  return Response("delet user userName:${userName}", 200)..text();
}

main() {
  Nepuro().server("127.0.0.1", 8080);
}
