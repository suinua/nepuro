import 'package:nepuro/nepuro.dart';

@Route.get("/welcome")
welcome(Request request) => Response('welcome to hoge', 200)..text();

@Route.post("/Hello", variablePath: "id", body: {"name": String, "age": int})
hello(Request request) {
  var id = request.variablePath;
  var body = request.body;
  print(id);
  print(body);

  return Response('Hello hoge!!', 200)..text();
}

main() {
  Nepuro().server("127.0.0.1",8080);
}
