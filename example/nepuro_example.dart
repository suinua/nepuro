import 'package:nepuro/nepuro.dart';

@Route.get("/welcome")
welcome(Request request) => Response('welcome to hoge', 200)..text();

@Route.post("/Hello", variablePath: "id", body: {"name": String, "age": int})
hello(Request request) {
  print(request.variablePath);
  print(request.body);

  return Response('Hello hoge!!', 200)..text();
}

main() {
  Nepuro().server();
}
