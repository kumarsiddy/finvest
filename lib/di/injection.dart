import 'package:bondgrid/di/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
//TODO:: Need to comeback later and change this string env to enum
// as after merging other pr for env
Future<GetIt> configureDependencies(String env) async => getIt.init(
      environment: env,
    );
