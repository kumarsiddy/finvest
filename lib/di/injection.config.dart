// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../domain/interfaces/i_connection_aware_facade.dart' as _i1004;
import '../env.dart' as _i578;
import '../infrastructure/api_services/connection_aware_facde.dart' as _i13;
import '../presentation/application/homepage/home_page_bloc.dart' as _i201;
import 'injection_register_module.dart' as _i931;

const String _uat = 'uat';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.singleton<_i578.Env>(() => registerModule.env);
    gh.lazySingleton<_i1004.IConnectionAwareFacade>(
      () => _i13.ConnectionAwareFacade(),
      registerFor: {
        _uat,
        _prod,
      },
    );
    gh.factory<_i201.HomePageBloc>(
        () => _i201.HomePageBloc(gh<_i1004.IConnectionAwareFacade>()));
    return this;
  }
}

class _$RegisterModule extends _i931.RegisterModule {}
