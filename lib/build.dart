library assets_builder;

import 'src/builder/asserts_builder.dart';

export 'build.dart' show run;

Future<void> run(List<String> args) async {
  return AssetsBuilder().build();
}
