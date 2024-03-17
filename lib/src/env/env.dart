import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env.dev', allowOptionalFields: true)
abstract class Env {
  @EnviedField(useConstantCase: true)
  static const String GEMINI_KEY= _Env.GEMINI_KEY;
  @EnviedField(useConstantCase: true)
  static const String OPENROUTER_API_KEY = _Env.OPENROUTER_API_KEY;
}