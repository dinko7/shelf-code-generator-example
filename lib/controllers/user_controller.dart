import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_code_generator_example/generator/annotations.dart';
import 'package:shelf_code_generator_example/models/user.dart';
import 'package:shelf_code_generator_example/utils/route_middleware_handler.dart';
import 'package:shelf_router/shelf_router.dart';

part 'user_controller.route.dart';

Handler authMiddleware(Handler innerHandler) {
  return (Request request) async {
    if (request.headers['Authorization'] == null) {
      return Response.forbidden('Not authorized');
    }
    return await innerHandler(request);
  };
}

@RouteController()
class UserController {
  @Use(authMiddleware)
  @Http(HttpMethod.post, '/users/<id>')
  Future<Response> updateUser(
    Request request,
    @Path('id') String userId,
    @Body() User user,
  ) async {
    // Implementation
    return Response.ok('User updated: $userId');
  }
}
