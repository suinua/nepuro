

import 'package:nepuro/nepuro.dart';

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