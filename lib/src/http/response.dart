import 'dart:convert';

import 'dart:io';

class Response {
  dynamic body;
  int status;
  ContentType contentType;

  text() {
    this.contentType = ContentType.text;
  }

  json() {
    this.body = jsonEncode(this.body);
    this.contentType = ContentType.json;
  }

  send(HttpResponse response) {
    response
      ..headers.contentType = this.contentType
      ..statusCode = this.status
      ..write(this.body)
      ..close();
  }

  Response(this.body, this.status) : this.contentType = ContentType.text;

  Response.ok(this.body)
      : this.contentType = ContentType.text,
        this.status = 200;

  Response.created(this.body)
      : this.contentType = ContentType.text,
        this.status = 201;

  Response.movedPermanently(this.body)
      : this.contentType = ContentType.text,
        this.status = 301;

  Response.notModified(this.body)
      : this.contentType = ContentType.text,
        this.status = 302;

  Response.badRequest(this.body)
      : this.contentType = ContentType.text,
        this.status = 400;

  Response.unauthorixed(this.body)
      : this.contentType = ContentType.text,
        this.status = 401;

  Response.forbidden(this.body)
      : this.contentType = ContentType.text,
        this.status = 403;

  Response.notFound(this.body)
      : this.contentType = ContentType.text,
        this.status = 404;

  Response.gone(this.body)
      : this.contentType = ContentType.text,
        this.status = 410;
}
