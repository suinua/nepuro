import 'package:nepuro/nepuro.dart';

@Operation.get("/welcome")
welcome() => Response('welcome to hoge',200)..text();

@Operation.get("/Hello")
hello() => Response('Hello hoge!!',200)..text();

main() {
  Nepuro();
}
