import 'package:finvest/env.dart';

abstract class IConfigs {
  IConfigs._();

  late Env env;
  late String baseUrl;
}

class UatConfigs implements IConfigs {
  @override
  String baseUrl = 'https://api.spacexdata.com/v4/';

  @override
  Env env = const Env(uat);
}

class ProdConfigs implements IConfigs {
  @override
  String baseUrl = 'https://api.spacexdata.com/v4/';

  @override
  Env env = const Env(prod);
}

IConfigs configReader = UatConfigs();

void initConfigReader(Env env) {
  switch (env.name) {
    case uat:
      configReader = UatConfigs();
      break;
    case prod:
      configReader = ProdConfigs();
      break;
  }
}
