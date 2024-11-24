import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generator/generator.dart'; // Changed to relative import

Builder shelfRouteBuilder(BuilderOptions options) => PartBuilder(
      [RouteGenerator()],
      '.route.dart',
      header: '// Generated code - do not modify by hand\n\n',
    );
