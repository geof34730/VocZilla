// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leaderboard_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeaderboardUser {

 String get pseudo; DateTime get createdAt; int get listPersoCount; String get imageAvatar; int get countGuidVocabularyLearned; int get countTrophy; int get rank;
/// Create a copy of LeaderboardUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaderboardUserCopyWith<LeaderboardUser> get copyWith => _$LeaderboardUserCopyWithImpl<LeaderboardUser>(this as LeaderboardUser, _$identity);

  /// Serializes this LeaderboardUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaderboardUser&&(identical(other.pseudo, pseudo) || other.pseudo == pseudo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.listPersoCount, listPersoCount) || other.listPersoCount == listPersoCount)&&(identical(other.imageAvatar, imageAvatar) || other.imageAvatar == imageAvatar)&&(identical(other.countGuidVocabularyLearned, countGuidVocabularyLearned) || other.countGuidVocabularyLearned == countGuidVocabularyLearned)&&(identical(other.countTrophy, countTrophy) || other.countTrophy == countTrophy)&&(identical(other.rank, rank) || other.rank == rank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pseudo,createdAt,listPersoCount,imageAvatar,countGuidVocabularyLearned,countTrophy,rank);

@override
String toString() {
  return 'LeaderboardUser(pseudo: $pseudo, createdAt: $createdAt, listPersoCount: $listPersoCount, imageAvatar: $imageAvatar, countGuidVocabularyLearned: $countGuidVocabularyLearned, countTrophy: $countTrophy, rank: $rank)';
}


}

/// @nodoc
abstract mixin class $LeaderboardUserCopyWith<$Res>  {
  factory $LeaderboardUserCopyWith(LeaderboardUser value, $Res Function(LeaderboardUser) _then) = _$LeaderboardUserCopyWithImpl;
@useResult
$Res call({
 String pseudo, DateTime createdAt, int listPersoCount, String imageAvatar, int countGuidVocabularyLearned, int countTrophy, int rank
});




}
/// @nodoc
class _$LeaderboardUserCopyWithImpl<$Res>
    implements $LeaderboardUserCopyWith<$Res> {
  _$LeaderboardUserCopyWithImpl(this._self, this._then);

  final LeaderboardUser _self;
  final $Res Function(LeaderboardUser) _then;

/// Create a copy of LeaderboardUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pseudo = null,Object? createdAt = null,Object? listPersoCount = null,Object? imageAvatar = null,Object? countGuidVocabularyLearned = null,Object? countTrophy = null,Object? rank = null,}) {
  return _then(_self.copyWith(
pseudo: null == pseudo ? _self.pseudo : pseudo // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,listPersoCount: null == listPersoCount ? _self.listPersoCount : listPersoCount // ignore: cast_nullable_to_non_nullable
as int,imageAvatar: null == imageAvatar ? _self.imageAvatar : imageAvatar // ignore: cast_nullable_to_non_nullable
as String,countGuidVocabularyLearned: null == countGuidVocabularyLearned ? _self.countGuidVocabularyLearned : countGuidVocabularyLearned // ignore: cast_nullable_to_non_nullable
as int,countTrophy: null == countTrophy ? _self.countTrophy : countTrophy // ignore: cast_nullable_to_non_nullable
as int,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaderboardUser].
extension LeaderboardUserPatterns on LeaderboardUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaderboardUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaderboardUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaderboardUser value)  $default,){
final _that = this;
switch (_that) {
case _LeaderboardUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaderboardUser value)?  $default,){
final _that = this;
switch (_that) {
case _LeaderboardUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String pseudo,  DateTime createdAt,  int listPersoCount,  String imageAvatar,  int countGuidVocabularyLearned,  int countTrophy,  int rank)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaderboardUser() when $default != null:
return $default(_that.pseudo,_that.createdAt,_that.listPersoCount,_that.imageAvatar,_that.countGuidVocabularyLearned,_that.countTrophy,_that.rank);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String pseudo,  DateTime createdAt,  int listPersoCount,  String imageAvatar,  int countGuidVocabularyLearned,  int countTrophy,  int rank)  $default,) {final _that = this;
switch (_that) {
case _LeaderboardUser():
return $default(_that.pseudo,_that.createdAt,_that.listPersoCount,_that.imageAvatar,_that.countGuidVocabularyLearned,_that.countTrophy,_that.rank);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String pseudo,  DateTime createdAt,  int listPersoCount,  String imageAvatar,  int countGuidVocabularyLearned,  int countTrophy,  int rank)?  $default,) {final _that = this;
switch (_that) {
case _LeaderboardUser() when $default != null:
return $default(_that.pseudo,_that.createdAt,_that.listPersoCount,_that.imageAvatar,_that.countGuidVocabularyLearned,_that.countTrophy,_that.rank);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaderboardUser implements LeaderboardUser {
  const _LeaderboardUser({required this.pseudo, required this.createdAt, required this.listPersoCount, required this.imageAvatar, required this.countGuidVocabularyLearned, required this.countTrophy, required this.rank});
  factory _LeaderboardUser.fromJson(Map<String, dynamic> json) => _$LeaderboardUserFromJson(json);

@override final  String pseudo;
@override final  DateTime createdAt;
@override final  int listPersoCount;
@override final  String imageAvatar;
@override final  int countGuidVocabularyLearned;
@override final  int countTrophy;
@override final  int rank;

/// Create a copy of LeaderboardUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaderboardUserCopyWith<_LeaderboardUser> get copyWith => __$LeaderboardUserCopyWithImpl<_LeaderboardUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaderboardUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaderboardUser&&(identical(other.pseudo, pseudo) || other.pseudo == pseudo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.listPersoCount, listPersoCount) || other.listPersoCount == listPersoCount)&&(identical(other.imageAvatar, imageAvatar) || other.imageAvatar == imageAvatar)&&(identical(other.countGuidVocabularyLearned, countGuidVocabularyLearned) || other.countGuidVocabularyLearned == countGuidVocabularyLearned)&&(identical(other.countTrophy, countTrophy) || other.countTrophy == countTrophy)&&(identical(other.rank, rank) || other.rank == rank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pseudo,createdAt,listPersoCount,imageAvatar,countGuidVocabularyLearned,countTrophy,rank);

@override
String toString() {
  return 'LeaderboardUser(pseudo: $pseudo, createdAt: $createdAt, listPersoCount: $listPersoCount, imageAvatar: $imageAvatar, countGuidVocabularyLearned: $countGuidVocabularyLearned, countTrophy: $countTrophy, rank: $rank)';
}


}

/// @nodoc
abstract mixin class _$LeaderboardUserCopyWith<$Res> implements $LeaderboardUserCopyWith<$Res> {
  factory _$LeaderboardUserCopyWith(_LeaderboardUser value, $Res Function(_LeaderboardUser) _then) = __$LeaderboardUserCopyWithImpl;
@override @useResult
$Res call({
 String pseudo, DateTime createdAt, int listPersoCount, String imageAvatar, int countGuidVocabularyLearned, int countTrophy, int rank
});




}
/// @nodoc
class __$LeaderboardUserCopyWithImpl<$Res>
    implements _$LeaderboardUserCopyWith<$Res> {
  __$LeaderboardUserCopyWithImpl(this._self, this._then);

  final _LeaderboardUser _self;
  final $Res Function(_LeaderboardUser) _then;

/// Create a copy of LeaderboardUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pseudo = null,Object? createdAt = null,Object? listPersoCount = null,Object? imageAvatar = null,Object? countGuidVocabularyLearned = null,Object? countTrophy = null,Object? rank = null,}) {
  return _then(_LeaderboardUser(
pseudo: null == pseudo ? _self.pseudo : pseudo // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,listPersoCount: null == listPersoCount ? _self.listPersoCount : listPersoCount // ignore: cast_nullable_to_non_nullable
as int,imageAvatar: null == imageAvatar ? _self.imageAvatar : imageAvatar // ignore: cast_nullable_to_non_nullable
as String,countGuidVocabularyLearned: null == countGuidVocabularyLearned ? _self.countGuidVocabularyLearned : countGuidVocabularyLearned // ignore: cast_nullable_to_non_nullable
as int,countTrophy: null == countTrophy ? _self.countTrophy : countTrophy // ignore: cast_nullable_to_non_nullable
as int,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
