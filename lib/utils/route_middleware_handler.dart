import 'dart:async';

import 'package:shelf/shelf.dart';

class RouteMiddlewareHandler {
  final Function handler;
  final List<Middleware> middlewares;

  RouteMiddlewareHandler(this.handler, this.middlewares);

  /// Match the signature of any shelf_router handler.
  FutureOr<Response> call(Request request) async {
    if (middlewares.isNotEmpty) {
      var pipeline = Pipeline();

      for (final middleware in middlewares) {
        pipeline = pipeline.addMiddleware(middleware);
      }

      return pipeline.addHandler(_handler).call(request);
    } else {
      return _handler.call(request);
    }
  }

  Future<Response> _handler(Request request) async {
    var map = request.context['shelf_router/params'] as Map<String, String>;

    dynamic result;

    try {
      result = Function.apply(handler, [request, ...map.values]);
    } on NoSuchMethodError catch (_) {
      try {
        result = handler();
      } on NoSuchMethodError catch (__) {
        result = handler(request);
      }
    }

    if (result is Future) {
      result = await result;
    }

    return result;
  }
}
