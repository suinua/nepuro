import 'dart:convert';

import 'package:nepuro/nepuro.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

@Path.get(r"/Plus/r[\d:first]/r[\d:second]")
plus(@Call.path("first") int first, @Call.path("second") int second) {
  return Response.ok("first + second = ${first + second}")..text();
}

@Path.get(r"/Calculation/r[\d:first]/r[[+-*/]:symbol]/r[\d:second]")
customCalculation(@Call.path("first") int first,
    @Call.path("symbol") String symbol, @Call.path("second") int second) {
  dynamic result;
  switch (symbol) {
    case "+":
      result = first + second;
      break;
    case "-":
      result = first - second;
      break;
    case "*":
      result = first * second;
      break;
    case "/":
      result = first / second;
      break;
    default:
      return Response.badRequest("symbol is incorrect");
  }
  return Response.ok("first $symbol second = $result")..text();
}

List<Map> books = [
  {
    "title": "Tsurezuregusa",
    "author": "Yosida Kenkou",
    "date": 1331,
  },
  {
    "title": "Makura-no-Soshi",
    "author": "Sei Shonagon",
    "date": 1001,
  },
  {
    "title": "Houjoki",
    "author": "Sei Shonagon",
    "date": 1212,
  },
];
@Path.get(r"/Books/[:title]")
getBook(@Call.path("title") String title) {
  return Response.ok(books.where((book) => book["title"] == title).toList())
    ..json();
}

@Path.get(r"/Books/[:title]/[:parameter]")
getBookData(@Call.path("title") String title,
    @Call.path("parameter") String parameter) {
  List<Map> matchBooks = books.where((book) => book["title"] == title).toList();
  if (matchBooks.isEmpty) {
    return Response.notFound("Title was 'A' book is not found");
  }
  return Response.ok(matchBooks.first[parameter])..text();
}

void main() {
  Nepuro().server();

  group("path variable test", () {
    test("normal path variable", () async {
      var body;
      await http
          .get("http://localhost:8080/Books/Makura-no-Soshi")
          .then((response) {
        body = jsonDecode(response.body);
      });
      expect(body, [
        {
          "title": "Makura-no-Soshi",
          "author": "Sei Shonagon",
          "date": 1001,
        }
      ]);
    });

    test("multiple path variables", () async {
      var body;
      await http
          .get("http://localhost:8080/Books/Makura-no-Soshi/author")
          .then((response) {
        body = response.body;
      });
      expect(body, "Sei Shonagon");
    });
  });

  group("path variable regexp test", () {
    test("plus", () async {
      var body;
      await http.get("http://localhost:8080/Plus/1/3").then((response) {
        body = response.body;
      });
      expect(body, "first + second = 4");
    });

    test("plus -not found", () async {
      var body;
      await http.get("http://localhost:8080/Plus/a/b").then((response) {
        body = response.body;
      });
      expect(body, "not found");
    });
  });
}
