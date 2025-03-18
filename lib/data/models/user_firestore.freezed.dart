// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_firestore.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserFirestore {
  String get uid;
  String get email;
  String get displayName;
  String get photoURL;
  String get providerId;
  bool get isEmailVerified;
  DateTime? get createdAt;
  String get fcmToken;

  /// Create a copy of UserFirestore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserFirestoreCopyWith<UserFirestore> get copyWith =>
      _$UserFirestoreCopyWithImpl<UserFirestore>(
          this as UserFirestore, _$identity);

  /// Serializes this UserFirestore to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserFirestore &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoURL, photoURL) ||
                other.photoURL == photoURL) &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.isEmailVerified, isEmailVerified) ||
                other.isEmailVerified == isEmailVerified) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uid, email, displayName,
      photoURL, providerId, isEmailVerified, createdAt, fcmToken);

  @override
  String toString() {
    return 'UserFirestore(uid: $uid, email: $email, displayName: $displayName, photoURL: $photoURL, providerId: $providerId, isEmailVerified: $isEmailVerified, createdAt: $createdAt, fcmToken: $fcmToken)';
  }
}

/// @nodoc
abstract mixin class $UserFirestoreCopyWith<$Res> {
  factory $UserFirestoreCopyWith(
          UserFirestore value, $Res Function(UserFirestore) _then) =
      _$UserFirestoreCopyWithImpl;
  @useResult
  $Res call(
      {String uid,
      String email,
      String displayName,
      String photoURL,
      String providerId,
      bool isEmailVerified,
      DateTime? createdAt,
      String fcmToken});
}

/// @nodoc
class _$UserFirestoreCopyWithImpl<$Res>
    implements $UserFirestoreCopyWith<$Res> {
  _$UserFirestoreCopyWithImpl(this._self, this._then);

  final UserFirestore _self;
  final $Res Function(UserFirestore) _then;

  /// Create a copy of UserFirestore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = null,
    Object? photoURL = null,
    Object? providerId = null,
    Object? isEmailVerified = null,
    Object? createdAt = freezed,
    Object? fcmToken = null,
  }) {
    return _then(_self.copyWith(
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _self.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      photoURL: null == photoURL
          ? _self.photoURL
          : photoURL // ignore: cast_nullable_to_non_nullable
              as String,
      providerId: null == providerId
          ? _self.providerId
          : providerId // ignore: cast_nullable_to_non_nullable
              as String,
      isEmailVerified: null == isEmailVerified
          ? _self.isEmailVerified
          : isEmailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fcmToken: null == fcmToken
          ? _self.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _UserFirestore implements UserFirestore {
  const _UserFirestore(
      {required this.uid,
      required this.email,
      required this.displayName,
      required this.photoURL,
      required this.providerId,
      required this.isEmailVerified,
      required this.createdAt,
      required this.fcmToken});
  factory _UserFirestore.fromJson(Map<String, dynamic> json) =>
      _$UserFirestoreFromJson(json);

  @override
  final String uid;
  @override
  final String email;
  @override
  final String displayName;
  @override
  final String photoURL;
  @override
  final String providerId;
  @override
  final bool isEmailVerified;
  @override
  final DateTime? createdAt;
  @override
  final String fcmToken;

  /// Create a copy of UserFirestore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserFirestoreCopyWith<_UserFirestore> get copyWith =>
      __$UserFirestoreCopyWithImpl<_UserFirestore>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UserFirestoreToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserFirestore &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoURL, photoURL) ||
                other.photoURL == photoURL) &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.isEmailVerified, isEmailVerified) ||
                other.isEmailVerified == isEmailVerified) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uid, email, displayName,
      photoURL, providerId, isEmailVerified, createdAt, fcmToken);

  @override
  String toString() {
    return 'UserFirestore(uid: $uid, email: $email, displayName: $displayName, photoURL: $photoURL, providerId: $providerId, isEmailVerified: $isEmailVerified, createdAt: $createdAt, fcmToken: $fcmToken)';
  }
}

/// @nodoc
abstract mixin class _$UserFirestoreCopyWith<$Res>
    implements $UserFirestoreCopyWith<$Res> {
  factory _$UserFirestoreCopyWith(
          _UserFirestore value, $Res Function(_UserFirestore) _then) =
      __$UserFirestoreCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String uid,
      String email,
      String displayName,
      String photoURL,
      String providerId,
      bool isEmailVerified,
      DateTime? createdAt,
      String fcmToken});
}

/// @nodoc
class __$UserFirestoreCopyWithImpl<$Res>
    implements _$UserFirestoreCopyWith<$Res> {
  __$UserFirestoreCopyWithImpl(this._self, this._then);

  final _UserFirestore _self;
  final $Res Function(_UserFirestore) _then;

  /// Create a copy of UserFirestore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = null,
    Object? photoURL = null,
    Object? providerId = null,
    Object? isEmailVerified = null,
    Object? createdAt = freezed,
    Object? fcmToken = null,
  }) {
    return _then(_UserFirestore(
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _self.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      photoURL: null == photoURL
          ? _self.photoURL
          : photoURL // ignore: cast_nullable_to_non_nullable
              as String,
      providerId: null == providerId
          ? _self.providerId
          : providerId // ignore: cast_nullable_to_non_nullable
              as String,
      isEmailVerified: null == isEmailVerified
          ? _self.isEmailVerified
          : isEmailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fcmToken: null == fcmToken
          ? _self.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
