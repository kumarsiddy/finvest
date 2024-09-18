// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'state_stores.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HomePageStore {
  List<FlSpot> get dataList => throw _privateConstructorUsedError;

  /// Create a copy of HomePageStore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomePageStoreCopyWith<HomePageStore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomePageStoreCopyWith<$Res> {
  factory $HomePageStoreCopyWith(
          HomePageStore value, $Res Function(HomePageStore) then) =
      _$HomePageStoreCopyWithImpl<$Res, HomePageStore>;
  @useResult
  $Res call({List<FlSpot> dataList});
}

/// @nodoc
class _$HomePageStoreCopyWithImpl<$Res, $Val extends HomePageStore>
    implements $HomePageStoreCopyWith<$Res> {
  _$HomePageStoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomePageStore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dataList = null,
  }) {
    return _then(_value.copyWith(
      dataList: null == dataList
          ? _value.dataList
          : dataList // ignore: cast_nullable_to_non_nullable
              as List<FlSpot>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomePageStoreImplCopyWith<$Res>
    implements $HomePageStoreCopyWith<$Res> {
  factory _$$HomePageStoreImplCopyWith(
          _$HomePageStoreImpl value, $Res Function(_$HomePageStoreImpl) then) =
      __$$HomePageStoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<FlSpot> dataList});
}

/// @nodoc
class __$$HomePageStoreImplCopyWithImpl<$Res>
    extends _$HomePageStoreCopyWithImpl<$Res, _$HomePageStoreImpl>
    implements _$$HomePageStoreImplCopyWith<$Res> {
  __$$HomePageStoreImplCopyWithImpl(
      _$HomePageStoreImpl _value, $Res Function(_$HomePageStoreImpl) _then)
      : super(_value, _then);

  /// Create a copy of HomePageStore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dataList = null,
  }) {
    return _then(_$HomePageStoreImpl(
      dataList: null == dataList
          ? _value._dataList
          : dataList // ignore: cast_nullable_to_non_nullable
              as List<FlSpot>,
    ));
  }
}

/// @nodoc

class _$HomePageStoreImpl implements _HomePageStore {
  const _$HomePageStoreImpl({required final List<FlSpot> dataList})
      : _dataList = dataList;

  final List<FlSpot> _dataList;
  @override
  List<FlSpot> get dataList {
    if (_dataList is EqualUnmodifiableListView) return _dataList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dataList);
  }

  @override
  String toString() {
    return 'HomePageStore(dataList: $dataList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomePageStoreImpl &&
            const DeepCollectionEquality().equals(other._dataList, _dataList));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_dataList));

  /// Create a copy of HomePageStore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomePageStoreImplCopyWith<_$HomePageStoreImpl> get copyWith =>
      __$$HomePageStoreImplCopyWithImpl<_$HomePageStoreImpl>(this, _$identity);
}

abstract class _HomePageStore implements HomePageStore {
  const factory _HomePageStore({required final List<FlSpot> dataList}) =
      _$HomePageStoreImpl;

  @override
  List<FlSpot> get dataList;

  /// Create a copy of HomePageStore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomePageStoreImplCopyWith<_$HomePageStoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CommonStore {
  Map<String, dynamic>? get args => throw _privateConstructorUsedError;

  /// Create a copy of CommonStore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommonStoreCopyWith<CommonStore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommonStoreCopyWith<$Res> {
  factory $CommonStoreCopyWith(
          CommonStore value, $Res Function(CommonStore) then) =
      _$CommonStoreCopyWithImpl<$Res, CommonStore>;
  @useResult
  $Res call({Map<String, dynamic>? args});
}

/// @nodoc
class _$CommonStoreCopyWithImpl<$Res, $Val extends CommonStore>
    implements $CommonStoreCopyWith<$Res> {
  _$CommonStoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommonStore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? args = freezed,
  }) {
    return _then(_value.copyWith(
      args: freezed == args
          ? _value.args
          : args // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommonStoreImplCopyWith<$Res>
    implements $CommonStoreCopyWith<$Res> {
  factory _$$CommonStoreImplCopyWith(
          _$CommonStoreImpl value, $Res Function(_$CommonStoreImpl) then) =
      __$$CommonStoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, dynamic>? args});
}

/// @nodoc
class __$$CommonStoreImplCopyWithImpl<$Res>
    extends _$CommonStoreCopyWithImpl<$Res, _$CommonStoreImpl>
    implements _$$CommonStoreImplCopyWith<$Res> {
  __$$CommonStoreImplCopyWithImpl(
      _$CommonStoreImpl _value, $Res Function(_$CommonStoreImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommonStore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? args = freezed,
  }) {
    return _then(_$CommonStoreImpl(
      args: freezed == args
          ? _value._args
          : args // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$CommonStoreImpl implements _CommonStore {
  const _$CommonStoreImpl({required final Map<String, dynamic>? args})
      : _args = args;

  final Map<String, dynamic>? _args;
  @override
  Map<String, dynamic>? get args {
    final value = _args;
    if (value == null) return null;
    if (_args is EqualUnmodifiableMapView) return _args;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'CommonStore(args: $args)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommonStoreImpl &&
            const DeepCollectionEquality().equals(other._args, _args));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_args));

  /// Create a copy of CommonStore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommonStoreImplCopyWith<_$CommonStoreImpl> get copyWith =>
      __$$CommonStoreImplCopyWithImpl<_$CommonStoreImpl>(this, _$identity);
}

abstract class _CommonStore implements CommonStore {
  const factory _CommonStore({required final Map<String, dynamic>? args}) =
      _$CommonStoreImpl;

  @override
  Map<String, dynamic>? get args;

  /// Create a copy of CommonStore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommonStoreImplCopyWith<_$CommonStoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
