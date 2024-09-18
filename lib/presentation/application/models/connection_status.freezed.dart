// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ConnectionStatus {
  ConnectivityResult get type => throw _privateConstructorUsedError;
  bool get working => throw _privateConstructorUsedError;

  /// Create a copy of ConnectionStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConnectionStatusCopyWith<ConnectionStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionStatusCopyWith<$Res> {
  factory $ConnectionStatusCopyWith(
          ConnectionStatus value, $Res Function(ConnectionStatus) then) =
      _$ConnectionStatusCopyWithImpl<$Res, ConnectionStatus>;
  @useResult
  $Res call({ConnectivityResult type, bool working});
}

/// @nodoc
class _$ConnectionStatusCopyWithImpl<$Res, $Val extends ConnectionStatus>
    implements $ConnectionStatusCopyWith<$Res> {
  _$ConnectionStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConnectionStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? working = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ConnectivityResult,
      working: null == working
          ? _value.working
          : working // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConnectionStatusImplCopyWith<$Res>
    implements $ConnectionStatusCopyWith<$Res> {
  factory _$$ConnectionStatusImplCopyWith(_$ConnectionStatusImpl value,
          $Res Function(_$ConnectionStatusImpl) then) =
      __$$ConnectionStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ConnectivityResult type, bool working});
}

/// @nodoc
class __$$ConnectionStatusImplCopyWithImpl<$Res>
    extends _$ConnectionStatusCopyWithImpl<$Res, _$ConnectionStatusImpl>
    implements _$$ConnectionStatusImplCopyWith<$Res> {
  __$$ConnectionStatusImplCopyWithImpl(_$ConnectionStatusImpl _value,
      $Res Function(_$ConnectionStatusImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConnectionStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? working = null,
  }) {
    return _then(_$ConnectionStatusImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ConnectivityResult,
      working: null == working
          ? _value.working
          : working // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ConnectionStatusImpl implements _ConnectionStatus {
  const _$ConnectionStatusImpl({required this.type, this.working = true});

  @override
  final ConnectivityResult type;
  @override
  @JsonKey()
  final bool working;

  @override
  String toString() {
    return 'ConnectionStatus(type: $type, working: $working)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionStatusImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.working, working) || other.working == working));
  }

  @override
  int get hashCode => Object.hash(runtimeType, type, working);

  /// Create a copy of ConnectionStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionStatusImplCopyWith<_$ConnectionStatusImpl> get copyWith =>
      __$$ConnectionStatusImplCopyWithImpl<_$ConnectionStatusImpl>(
          this, _$identity);
}

abstract class _ConnectionStatus implements ConnectionStatus {
  const factory _ConnectionStatus(
      {required final ConnectivityResult type,
      final bool working}) = _$ConnectionStatusImpl;

  @override
  ConnectivityResult get type;
  @override
  bool get working;

  /// Create a copy of ConnectionStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionStatusImplCopyWith<_$ConnectionStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
