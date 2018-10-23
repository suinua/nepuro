class Response {
  dynamic body;
  int status;
  String contentType;

  text(){
    this.contentType = "text/plain";
  }
  json(){
    this.contentType = "application/json";
  }

  send(response){
    response.headers.set("Content-Type", this.contentType);
    response.statusCode = this.status;
    response.write(this.body);
    response.close();
  }

  Response(this.body,this.status):this.contentType = "text/plain";
}