# Nepuro
REST API FRAMEWORK

# English  
###### This library is incomplete.  

I made this framework by practice for dart.  
I am not full of programming history one year.  
I would be pleased if you could tell me about reports, requests, and improvements.  

### how to use  

Pleas read example  
https://github.com/suinua/nepuro/blob/master/example/nepuro_example.dart  

Pub  
```yaml
dependencies:
  nepuro:
    git: https://github.com/suinua/nepuro.git
```

example code  
```dart
import 'package:nepuro/nepuro.dart';

//GET: http://localhost:8080/Hello
// >> Hello World
@Path.get("/Hello")
hello() {
  return Response.ok("Hello World")..text();
}

main() {
  Nepuro().server();
}
```

# 日本語  
###### このライブラリはまだ未完成です。  

これは私が練習のために作ったフレームワークです。  
私はプログラミング歴が１年にも満たない初心者なので。  
改善点や要望、バグの報告などを伝えてもらえると幸いです。  

### 使い方  

サンプルを見てください
https://github.com/suinua/nepuro/blob/master/example/nepuro_example.dart  

Pub  
```yaml
dependencies:
  nepuro:
    git: https://github.com/suinua/nepuro.git
```

サンプルコード  
```dart
import 'package:nepuro/nepuro.dart';

//GET: http://localhost:8080/Hello
// >> Hello World
@Path.get("/Hello")
hello() {
  return Response.ok("Hello World")..text();
}

main() {
  Nepuro().server();
}
```