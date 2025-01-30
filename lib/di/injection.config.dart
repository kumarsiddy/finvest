// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../data/api_service/connection_listener.dart' as _i198;
import '../domain/interfaces/i_connection_listener.dart' as _i85;
import '../presentation/base/common_bloc.dart' as _i385;
import 'injection_register_module.dart' as _i931;

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
    gh.singleton<_i895.Connectivity>(() => registerModule.connectivity);
    gh.lazySingleton<_i85.IConnectionListener>(
        () => _i198.ConnectionListener(gh<_i895.Connectivity>()));
    gh.factory<_i385.CommonBloc>(
        () => _i385.CommonBloc(gh<_i85.IConnectionListener>()));
    return this;
  }
}

class _$RegisterModule extends _i931.RegisterModule {}
