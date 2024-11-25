import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:shelf_code_generator_example/generator/annotations.dart';
import 'package:source_gen/source_gen.dart';

class RouteGenerator extends GeneratorForAnnotation<RouteController> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'RouteGenerator can only be applied to classes.',
        element: element,
      );
    }

    final className = element.name;

    return '''
class ${className}Router {
  final Router _router = Router();
  final $className _controller;
  
  ${className}Router(this._controller) {
    ${_generateRoutes(element)}
  }

  Handler get handler => _router.call;
}
''';
  }

  String _generateRoutes(ClassElement classElement) {
    final routes = StringBuffer();
    final foundRoutes = _findRoutes(classElement);

    for (var route in foundRoutes) {
      routes.writeln('    _router.add(');
      routes.writeln('      ${route.httpAnnotation.method}.name,');
      routes.writeln('      \'${route.httpAnnotation.path}\',');
      routes.writeln('      RouteMiddlewareHandler(');

      // Generate the handler function
      routes.writeln(
          '        (request, ${_generateParameterList(route)}) async {');

      // Add body parameter
      if (route.bodyParam != null) {
        routes.writeln(
            '          final bodyJson = await request.readAsString();');
        routes.writeln(
            '          final ${route.bodyParam!.name} = ${route.bodyParam!.type}.fromJson(json.decode(bodyJson));');
      }

      // Generate method call
      routes.write('          return _controller.${route.methodName}(request');
      for (var param in route.pathParams) {
        routes.write(', ${param.name}');
      }
      if (route.bodyParam != null) {
        routes.write(', ${route.bodyParam!.name}');
      }
      routes.writeln(');');
      routes.writeln('        },');

      // Add middlewares
      routes.writeln('        [${route.middlewares.join(', ')}],');
      routes.writeln('      ).call,');
      routes.writeln('    );');
    }

    return routes.toString();
  }

  String _generateParameterList(_Route route) {
    final params = route.pathParams.map((p) => p.name).join(', ');
    return params;
  }

  List<_Route> _findRoutes(ClassElement classElement) {
    final routes = <_Route>[];

    for (var method in classElement.methods) {
      final httpAnnotation = _getHttpAnnotation(method);
      if (httpAnnotation == null) continue;

      final middlewares = _getMiddlewares(method);
      final pathParams = <_PathAnnotation>[];
      _BodyParameter? bodyParam;

      for (var param in method.parameters) {
        final pathAnnotation = _getPathAnnotation(param);
        if (pathAnnotation != null) {
          pathParams.add(pathAnnotation);
          continue;
        }

        if (const TypeChecker.fromRuntime(Body).hasAnnotationOf(param)) {
          bodyParam = _BodyParameter(
            name: param.name,
            type: param.type.getDisplayString(),
          );
        }
      }

      routes.add(_Route(
        methodName: method.name,
        httpAnnotation: httpAnnotation,
        middlewares: middlewares,
        pathParams: pathParams,
        bodyParam: bodyParam,
      ));
    }

    return routes;
  }

  _HttpAnnotation? _getHttpAnnotation(MethodElement method) {
    final annotation =
        const TypeChecker.fromRuntime(Http).firstAnnotationOf(method);
    if (annotation == null) return null;

    final reader = ConstantReader(annotation);

    // Get the method enum
    final methodObj = reader.read('method');
    final pathObj = reader.read('path');

    return _HttpAnnotation(
      method: methodObj.revive().accessor,
      path: pathObj.stringValue,
    );
  }

  List<String> _getMiddlewares(MethodElement method) {
    return const TypeChecker.fromRuntime(Use)
        .annotationsOf(method)
        .map((annotation) {
      final reader = ConstantReader(annotation);
      final middlewareObj = reader.read('middleware');
      return middlewareObj.revive().accessor;
    }).toList();
  }

  _PathAnnotation? _getPathAnnotation(ParameterElement param) {
    final annotation =
        const TypeChecker.fromRuntime(Path).firstAnnotationOf(param);
    if (annotation == null) return null;

    final reader = ConstantReader(annotation);
    return _PathAnnotation(
      name: reader.read('name').stringValue,
    );
  }
}

class _Route {
  final String methodName;
  final _HttpAnnotation httpAnnotation;
  final List<String> middlewares;
  final List<_PathAnnotation> pathParams;
  final _BodyParameter? bodyParam;

  _Route({
    required this.methodName,
    required this.httpAnnotation,
    required this.middlewares,
    required this.pathParams,
    this.bodyParam,
  });
}

class _HttpAnnotation {
  final String method;
  final String path;

  const _HttpAnnotation({
    required this.method,
    required this.path,
  });
}

class _PathAnnotation {
  final String name;

  const _PathAnnotation({
    required this.name,
  });
}

class _BodyParameter {
  final String name;
  final String type;

  const _BodyParameter({
    required this.name,
    required this.type,
  });
}
