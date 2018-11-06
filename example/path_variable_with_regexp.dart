import 'package:nepuro/nepuro.dart';

@Path.get(r"/Plus/r[\d:first]/r[\d:second]")
plus(@Call.path("first") int first, @Call.path("second") int second) {
  return Response.ok("first + second = ${first + second}")..text();
}

@Path.get(r"/Calculation/r[\d:first]/r[[+-*/]:symbol]/r[\d:second]")
customCalculation(@Call.path("first") int first,
    @Call.path("symbol") String symbol, @Call.path("second") int second) {
  dynamic result;
  switch (symbol) {
    case "+":
      result = first + second;
      break;
    case "-":
      result = first - second;
      break;
    case "*":
      result = first * second;
      break;
    case "/":
      result = first / second;
      break;
    default:
      return Response.badRequest("symbol is incorrect");
  }
  return Response.ok("first $symbol second = $result")..text();
}

main(){
  Nepuro().server();
}