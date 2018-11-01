class Call {
  final String type;
  final String contentType;
  
  const Call.path():this.type = "path",this.contentType = null;
  const Call.body({this.contentType}):this.type = "body";
}