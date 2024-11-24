import 'package:meta/meta_meta.dart';
import 'package:shelf/shelf.dart';

typedef MiddlewareFunction = Handler Function(Handler handler);

enum HttpMethod { get, post, put, delete, patch }

@Target({TargetKind.method, TargetKind.function})
class Http {
  final HttpMethod method;
  final String path;

  const Http(this.method, this.path);
}

@Target({TargetKind.method, TargetKind.function})
class Use {
  final MiddlewareFunction middleware;

  const Use(this.middleware);
}

@Target({TargetKind.parameter})
class Path {
  final String name;

  const Path(this.name);
}

@Target({TargetKind.parameter})
class Body {
  const Body();
}

@Target({TargetKind.classType})
class RouteController {
  const RouteController();
}
