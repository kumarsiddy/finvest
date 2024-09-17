// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../domain/interfaces/i_connection_aware_facade.dart' as _i4;
import '../env.dart' as _i3;
import '../infrastructure/api_services/connection_aware_facde.dart' as _i5;
import '../presentation/application/homepage/home_page_bloc.dart' as _i6;
import 'injection_register_module.dart' as _i7;

const String _uat = 'uat';
const String _prod = 'prod';

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.singleton<_i3.Env>(() => registerModule.env);
    gh.lazySingleton<_i4.IConnectionAwareFacade>(
      () => _i5.ConnectionAwareFacade(),
      registerFor: {
        _uat,
        _prod,
      },
    );
    gh.factory<_i6.HomePageBloc>(
        () => _i6.HomePageBloc(gh<_i4.IConnectionAwareFacade>()));
    return this;
  }
}

class _$RegisterModule extends _i7.RegisterModule {}
