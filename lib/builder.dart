import 'package:build/build.dart';
import 'package:shelf_code_generator_example/generator/generator.dart';
import 'package:source_gen/source_gen.dart';

Builder shelfRouteBuilder(BuilderOptions options) => PartBuilder(
      [RouteGenerator()],
      '.route.dart',
      header: '// Generated code - do not modify by hand\n\n',
    );
