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

  Response(this.body,this.status):this.contentType = "text/plain";
}