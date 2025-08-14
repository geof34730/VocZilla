// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
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
  String get pseudo;
  String get photoURL;
  String get imageAvatar;
  List<String> get fcmTokens;
  DateTime? get createdAt;

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
            (identical(other.pseudo, pseudo) || other.pseudo == pseudo) &&
            (identical(other.photoURL, photoURL) ||
                other.photoURL == photoURL) &&
            (identical(other.imageAvatar, imageAvatar) ||
                other.imageAvatar == imageAvatar) &&
            const DeepCollectionEquality().equals(other.fcmTokens, fcmTokens) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uid, pseudo, photoURL,
      imageAvatar, const DeepCollectionEquality().hash(fcmTokens), createdAt);

  @override
  String toString() {
    return 'UserFirestore(uid: $uid, pseudo: $pseudo, photoURL: $photoURL, imageAvatar: $imageAvatar, fcmTokens: $fcmTokens, createdAt: $createdAt)';
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
      String pseudo,
      String photoURL,
      String imageAvatar,
      List<String> fcmTokens,
      DateTime? createdAt});
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
    Object? pseudo = null,
    Object? photoURL = null,
    Object? imageAvatar = null,
    Object? fcmTokens = null,
    Object? createdAt = freezed,
  }) {
    return _then(_self.copyWith(
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      pseudo: null == pseudo
          ? _self.pseudo
          : pseudo // ignore: cast_nullable_to_non_nullable
              as String,
      photoURL: null == photoURL
          ? _self.photoURL
          : photoURL // ignore: cast_nullable_to_non_nullable
              as String,
      imageAvatar: null == imageAvatar
          ? _self.imageAvatar
          : imageAvatar // ignore: cast_nullable_to_non_nullable
              as String,
      fcmTokens: null == fcmTokens
          ? _self.fcmTokens
          : fcmTokens // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [UserFirestore].
extension UserFirestorePatterns on UserFirestore {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_UserFirestore value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserFirestore() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_UserFirestore value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserFirestore():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_UserFirestore value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserFirestore() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String uid, String pseudo, String photoURL,
            String imageAvatar, List<String> fcmTokens, DateTime? createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserFirestore() when $default != null:
        return $default(_that.uid, _that.pseudo, _that.photoURL,
            _that.imageAvatar, _that.fcmTokens, _that.createdAt);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String uid, String pseudo, String photoURL,
            String imageAvatar, List<String> fcmTokens, DateTime? createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserFirestore():
        return $default(_that.uid, _that.pseudo, _that.photoURL,
            _that.imageAvatar, _that.fcmTokens, _that.createdAt);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String uid, String pseudo, String photoURL,
            String imageAvatar, List<String> fcmTokens, DateTime? createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserFirestore() when $default != null:
        return $default(_that.uid, _that.pseudo, _that.photoURL,
            _that.imageAvatar, _that.fcmTokens, _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _UserFirestore implements UserFirestore {
  const _UserFirestore(
      {required this.uid,
      this.pseudo = 'Guest',
      this.photoURL = '',
      this.imageAvatar = '',
      final List<String> fcmTokens = const [],
      this.createdAt})
      : _fcmTokens = fcmTokens;
  factory _UserFirestore.fromJson(Map<String, dynamic> json) =>
      _$UserFirestoreFromJson(json);

  @override
  final String uid;
  @override
  @JsonKey()
  final String pseudo;
  @override
  @JsonKey()
  final String photoURL;
  @override
  @JsonKey()
  final String imageAvatar;
  final List<String> _fcmTokens;
  @override
  @JsonKey()
  List<String> get fcmTokens {
    if (_fcmTokens is EqualUnmodifiableListView) return _fcmTokens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fcmTokens);
  }

  @override
  final DateTime? createdAt;

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
            (identical(other.pseudo, pseudo) || other.pseudo == pseudo) &&
            (identical(other.photoURL, photoURL) ||
                other.photoURL == photoURL) &&
            (identical(other.imageAvatar, imageAvatar) ||
                other.imageAvatar == imageAvatar) &&
            const DeepCollectionEquality()
                .equals(other._fcmTokens, _fcmTokens) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uid, pseudo, photoURL,
      imageAvatar, const DeepCollectionEquality().hash(_fcmTokens), createdAt);

  @override
  String toString() {
    return 'UserFirestore(uid: $uid, pseudo: $pseudo, photoURL: $photoURL, imageAvatar: $imageAvatar, fcmTokens: $fcmTokens, createdAt: $createdAt)';
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
      String pseudo,
      String photoURL,
      String imageAvatar,
      List<String> fcmTokens,
      DateTime? createdAt});
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
    Object? pseudo = null,
    Object? photoURL = null,
    Object? imageAvatar = null,
    Object? fcmTokens = null,
    Object? createdAt = freezed,
  }) {
    return _then(_UserFirestore(
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      pseudo: null == pseudo
          ? _self.pseudo
          : pseudo // ignore: cast_nullable_to_non_nullable
              as String,
      photoURL: null == photoURL
          ? _self.photoURL
          : photoURL // ignore: cast_nullable_to_non_nullable
              as String,
      imageAvatar: null == imageAvatar
          ? _self.imageAvatar
          : imageAvatar // ignore: cast_nullable_to_non_nullable
              as String,
      fcmTokens: null == fcmTokens
          ? _self._fcmTokens
          : fcmTokens // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
