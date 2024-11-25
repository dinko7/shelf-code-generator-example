import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_code_generator_example/controllers/user_controller.dart';

void main(List<String> args) async {
  final controller = UserController();
  final router = UserControllerRouter(controller);

  final handler =
      Pipeline().addMiddleware(logRequests()).addHandler(router.handler);

  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
