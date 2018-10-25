class Route {
  final String path;
  final String method;
  final String variablePath;
  final Type body;
  final Map<String, Type> necessaryField;

  const Route.get(this.path, {this.variablePath})
      : this.method = "GET",
        this.necessaryField = null,
        this.body = null;

  const Route.post(this.path,
      {this.variablePath, this.necessaryField, this.body})
      : this.method = "POST";

  const Route.put(
    this.path, {
    this.variablePath,
    this.necessaryField,
    this.body,
  }) : this.method = "PUT";

  const Route.delete(this.path, {this.variablePath})
      : this.method = "DELETE",
        this.necessaryField = null,
        this.body = null;

  bool validateBody(Map requestBody) {
    bool result = true;
    if (requestBody.length < this.necessaryField.length) {
      result = false;
      
    } else {
      this.necessaryField.forEach((name, type) {
        if (!(requestBody.containsKey(name) &&
            requestBody[name].runtimeType == type)) {
          result = false;
        }
      });
    }
    return result;
  }
}
