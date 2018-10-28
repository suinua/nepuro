class Route {
  final String path;
  final String method;

  const Route.get(this.path) : this.method = "GET";

  const Route.post(this.path) : this.method = "POST";

  const Route.put(this.path) : this.method = "PUT";

  const Route.delete(this.path) : this.method = "DELETE";
}
