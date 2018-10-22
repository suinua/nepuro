class Route {
  final String path;
  final String method;
  final String variablePath;
  final Map<String, Type> body;

  const Route.get(this.path, {this.variablePath})
      : this.method = "GET",
        this.body = null;

  const Route.post(this.path, {this.variablePath, this.body})
      : this.method = "POST";

  const Route.put(this.path, {this.variablePath, this.body})
      : this.method = "PUT";

  const Route.delete(this.path, {this.variablePath})
      : this.method = "DELETE",
        this.body = null;

  bool isBodyCorrect(Map requestBody) {
    bool result = true;
    if (requestBody.length >= this.body.length) {
      this.body.forEach((name, type) {
        if (!(requestBody.containsKey(name) &&
            requestBody[name].runtimeType == type)) {
          result = false;
        }
      });
    }
    return result;
  }
}
