class Call {
  final String type;
  
  final String contentType;

  final String pathName;
  
  const Call.path(this.pathName):this.type = "path",this.contentType = null;
  const Call.body({this.contentType}):this.type = "body",this.pathName = null;
}