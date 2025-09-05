// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leaderboard_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeaderboardData {

// Les propriétés ne changent pas
 List<LeaderboardUser> get topUsers; int get currentUserRank; int get totalWordsInLevel;
/// Create a copy of LeaderboardData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaderboardDataCopyWith<LeaderboardData> get copyWith => _$LeaderboardDataCopyWithImpl<LeaderboardData>(this as LeaderboardData, _$identity);

  /// Serializes this LeaderboardData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaderboardData&&const DeepCollectionEquality().equals(other.topUsers, topUsers)&&(identical(other.currentUserRank, currentUserRank) || other.currentUserRank == currentUserRank)&&(identical(other.totalWordsInLevel, totalWordsInLevel) || other.totalWordsInLevel == totalWordsInLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(topUsers),currentUserRank,totalWordsInLevel);

@override
String toString() {
  return 'LeaderboardData(topUsers: $topUsers, currentUserRank: $currentUserRank, totalWordsInLevel: $totalWordsInLevel)';
}


}

/// @nodoc
abstract mixin class $LeaderboardDataCopyWith<$Res>  {
  factory $LeaderboardDataCopyWith(LeaderboardData value, $Res Function(LeaderboardData) _then) = _$LeaderboardDataCopyWithImpl;
@useResult
$Res call({
 List<LeaderboardUser> topUsers, int currentUserRank, int totalWordsInLevel
});




}
/// @nodoc
class _$LeaderboardDataCopyWithImpl<$Res>
    implements $LeaderboardDataCopyWith<$Res> {
  _$LeaderboardDataCopyWithImpl(this._self, this._then);

  final LeaderboardData _self;
  final $Res Function(LeaderboardData) _then;

/// Create a copy of LeaderboardData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? topUsers = null,Object? currentUserRank = null,Object? totalWordsInLevel = null,}) {
  return _then(_self.copyWith(
topUsers: null == topUsers ? _self.topUsers : topUsers // ignore: cast_nullable_to_non_nullable
as List<LeaderboardUser>,currentUserRank: null == currentUserRank ? _self.currentUserRank : currentUserRank // ignore: cast_nullable_to_non_nullable
as int,totalWordsInLevel: null == totalWordsInLevel ? _self.totalWordsInLevel : totalWordsInLevel // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaderboardData].
extension LeaderboardDataPatterns on LeaderboardData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaderboardData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaderboardData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaderboardData value)  $default,){
final _that = this;
switch (_that) {
case _LeaderboardData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaderboardData value)?  $default,){
final _that = this;
switch (_that) {
case _LeaderboardData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LeaderboardUser> topUsers,  int currentUserRank,  int totalWordsInLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaderboardData() when $default != null:
return $default(_that.topUsers,_that.currentUserRank,_that.totalWordsInLevel);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LeaderboardUser> topUsers,  int currentUserRank,  int totalWordsInLevel)  $default,) {final _that = this;
switch (_that) {
case _LeaderboardData():
return $default(_that.topUsers,_that.currentUserRank,_that.totalWordsInLevel);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LeaderboardUser> topUsers,  int currentUserRank,  int totalWordsInLevel)?  $default,) {final _that = this;
switch (_that) {
case _LeaderboardData() when $default != null:
return $default(_that.topUsers,_that.currentUserRank,_that.totalWordsInLevel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaderboardData implements LeaderboardData {
  const _LeaderboardData({required final  List<LeaderboardUser> topUsers, required this.currentUserRank, required this.totalWordsInLevel}): _topUsers = topUsers;
  factory _LeaderboardData.fromJson(Map<String, dynamic> json) => _$LeaderboardDataFromJson(json);

// Les propriétés ne changent pas
 final  List<LeaderboardUser> _topUsers;
// Les propriétés ne changent pas
@override List<LeaderboardUser> get topUsers {
  if (_topUsers is EqualUnmodifiableListView) return _topUsers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topUsers);
}

@override final  int currentUserRank;
@override final  int totalWordsInLevel;

/// Create a copy of LeaderboardData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaderboardDataCopyWith<_LeaderboardData> get copyWith => __$LeaderboardDataCopyWithImpl<_LeaderboardData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaderboardDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaderboardData&&const DeepCollectionEquality().equals(other._topUsers, _topUsers)&&(identical(other.currentUserRank, currentUserRank) || other.currentUserRank == currentUserRank)&&(identical(other.totalWordsInLevel, totalWordsInLevel) || other.totalWordsInLevel == totalWordsInLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_topUsers),currentUserRank,totalWordsInLevel);

@override
String toString() {
  return 'LeaderboardData(topUsers: $topUsers, currentUserRank: $currentUserRank, totalWordsInLevel: $totalWordsInLevel)';
}


}

/// @nodoc
abstract mixin class _$LeaderboardDataCopyWith<$Res> implements $LeaderboardDataCopyWith<$Res> {
  factory _$LeaderboardDataCopyWith(_LeaderboardData value, $Res Function(_LeaderboardData) _then) = __$LeaderboardDataCopyWithImpl;
@override @useResult
$Res call({
 List<LeaderboardUser> topUsers, int currentUserRank, int totalWordsInLevel
});




}
/// @nodoc
class __$LeaderboardDataCopyWithImpl<$Res>
    implements _$LeaderboardDataCopyWith<$Res> {
  __$LeaderboardDataCopyWithImpl(this._self, this._then);

  final _LeaderboardData _self;
  final $Res Function(_LeaderboardData) _then;

/// Create a copy of LeaderboardData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? topUsers = null,Object? currentUserRank = null,Object? totalWordsInLevel = null,}) {
  return _then(_LeaderboardData(
topUsers: null == topUsers ? _self._topUsers : topUsers // ignore: cast_nullable_to_non_nullable
as List<LeaderboardUser>,currentUserRank: null == currentUserRank ? _self.currentUserRank : currentUserRank // ignore: cast_nullable_to_non_nullable
as int,totalWordsInLevel: null == totalWordsInLevel ? _self.totalWordsInLevel : totalWordsInLevel // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
