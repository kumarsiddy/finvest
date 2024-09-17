import 'package:finvest/di/injection.config.dart';
import 'package:finvest/env.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<GetIt> configureDependencies(Env env) async => getIt.init(
      environment: env.name,
    );
