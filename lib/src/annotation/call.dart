class Call {
  final String type;

  final pathVarName;
  
  final String contentType;

  const Call.path(this.pathVarName):this.type = "path",this.contentType = null;
  const Call.body({this.contentType}):this.type = "body",this.pathVarName = null;
}