class Call {
  final String type;

  final pathParameterName;
  
  final String contentType;

  const Call.path(this.pathParameterName):this.type = "path",this.contentType = null;
  const Call.body({this.contentType}):this.type = "body",this.pathParameterName = null;
}