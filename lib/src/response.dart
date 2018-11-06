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
        this.status = HttpStatus.ok;

  Response.created(this.body)
      : this.contentType = ContentType.text,
        this.status = HttpStatus.created;

  Response.movedPermanently(this.body)
      : this.contentType = ContentType.text,
        this.status = HttpStatus.movedPermanently;

  Response.notModified(this.body)
      : this.contentType = ContentType.text,
        this.status = HttpStatus.notModified;

  Response.badRequest(this.body)
      : this.contentType = ContentType.text,
        this.status = HttpStatus.badRequest;

  Response.unauthorixed(this.body)
      : this.contentType = ContentType.text,
        this.status = HttpStatus.unauthorized;

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
