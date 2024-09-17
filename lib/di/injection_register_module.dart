import 'package:finvest/config_options.dart';
import 'package:finvest/env.dart';
import 'package:injectable/injectable.dart';

@module
abstract class RegisterModule {
  @singleton
  Env get env => configReader.env;
}
