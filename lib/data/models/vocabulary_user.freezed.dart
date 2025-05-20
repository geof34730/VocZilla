// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vocabulary_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VocabulaireUser {
  @JsonKey(name: "ListPerso")
  List<ListPerso> get listPerso;
  @JsonKey(name: "ListTheme")
  List<ListTheme> get listTheme;
  @JsonKey(name: "ListGuidVocabularyLearned")
  List<String> get listGuidVocabularyLearned;
  @JsonKey(name: "CountVocabulaireAll", defaultValue: 0)
  int get countVocabulaireAll;

  /// Create a copy of VocabulaireUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VocabulaireUserCopyWith<VocabulaireUser> get copyWith =>
      _$VocabulaireUserCopyWithImpl<VocabulaireUser>(
          this as VocabulaireUser, _$identity);

  /// Serializes this VocabulaireUser to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VocabulaireUser &&
            const DeepCollectionEquality().equals(other.listPerso, listPerso) &&
            const DeepCollectionEquality().equals(other.listTheme, listTheme) &&
            const DeepCollectionEquality().equals(
                other.listGuidVocabularyLearned, listGuidVocabularyLearned) &&
            (identical(other.countVocabulaireAll, countVocabulaireAll) ||
                other.countVocabulaireAll == countVocabulaireAll));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(listPerso),
      const DeepCollectionEquality().hash(listTheme),
      const DeepCollectionEquality().hash(listGuidVocabularyLearned),
      countVocabulaireAll);

  @override
  String toString() {
    return 'VocabulaireUser(listPerso: $listPerso, listTheme: $listTheme, listGuidVocabularyLearned: $listGuidVocabularyLearned, countVocabulaireAll: $countVocabulaireAll)';
  }
}

/// @nodoc
abstract mixin class $VocabulaireUserCopyWith<$Res> {
  factory $VocabulaireUserCopyWith(
          VocabulaireUser value, $Res Function(VocabulaireUser) _then) =
      _$VocabulaireUserCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: "ListPerso") List<ListPerso> listPerso,
      @JsonKey(name: "ListTheme") List<ListTheme> listTheme,
      @JsonKey(name: "ListGuidVocabularyLearned")
      List<String> listGuidVocabularyLearned,
      @JsonKey(name: "CountVocabulaireAll", defaultValue: 0)
      int countVocabulaireAll});
}

/// @nodoc
class _$VocabulaireUserCopyWithImpl<$Res>
    implements $VocabulaireUserCopyWith<$Res> {
  _$VocabulaireUserCopyWithImpl(this._self, this._then);

  final VocabulaireUser _self;
  final $Res Function(VocabulaireUser) _then;

  /// Create a copy of VocabulaireUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listPerso = null,
    Object? listTheme = null,
    Object? listGuidVocabularyLearned = null,
    Object? countVocabulaireAll = null,
  }) {
    return _then(_self.copyWith(
      listPerso: null == listPerso
          ? _self.listPerso
          : listPerso // ignore: cast_nullable_to_non_nullable
              as List<ListPerso>,
      listTheme: null == listTheme
          ? _self.listTheme
          : listTheme // ignore: cast_nullable_to_non_nullable
              as List<ListTheme>,
      listGuidVocabularyLearned: null == listGuidVocabularyLearned
          ? _self.listGuidVocabularyLearned
          : listGuidVocabularyLearned // ignore: cast_nullable_to_non_nullable
              as List<String>,
      countVocabulaireAll: null == countVocabulaireAll
          ? _self.countVocabulaireAll
          : countVocabulaireAll // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _VocabulaireUser implements VocabulaireUser {
  const _VocabulaireUser(
      {@JsonKey(name: "ListPerso") required final List<ListPerso> listPerso,
      @JsonKey(name: "ListTheme") required final List<ListTheme> listTheme,
      @JsonKey(name: "ListGuidVocabularyLearned")
      required final List<String> listGuidVocabularyLearned,
      @JsonKey(name: "CountVocabulaireAll", defaultValue: 0)
      required this.countVocabulaireAll})
      : _listPerso = listPerso,
        _listTheme = listTheme,
        _listGuidVocabularyLearned = listGuidVocabularyLearned;
  factory _VocabulaireUser.fromJson(Map<String, dynamic> json) =>
      _$VocabulaireUserFromJson(json);

  final List<ListPerso> _listPerso;
  @override
  @JsonKey(name: "ListPerso")
  List<ListPerso> get listPerso {
    if (_listPerso is EqualUnmodifiableListView) return _listPerso;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_listPerso);
  }

  final List<ListTheme> _listTheme;
  @override
  @JsonKey(name: "ListTheme")
  List<ListTheme> get listTheme {
    if (_listTheme is EqualUnmodifiableListView) return _listTheme;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_listTheme);
  }

  final List<String> _listGuidVocabularyLearned;
  @override
  @JsonKey(name: "ListGuidVocabularyLearned")
  List<String> get listGuidVocabularyLearned {
    if (_listGuidVocabularyLearned is EqualUnmodifiableListView)
      return _listGuidVocabularyLearned;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_listGuidVocabularyLearned);
  }

  @override
  @JsonKey(name: "CountVocabulaireAll", defaultValue: 0)
  final int countVocabulaireAll;

  /// Create a copy of VocabulaireUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$VocabulaireUserCopyWith<_VocabulaireUser> get copyWith =>
      __$VocabulaireUserCopyWithImpl<_VocabulaireUser>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$VocabulaireUserToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _VocabulaireUser &&
            const DeepCollectionEquality()
                .equals(other._listPerso, _listPerso) &&
            const DeepCollectionEquality()
                .equals(other._listTheme, _listTheme) &&
            const DeepCollectionEquality().equals(
                other._listGuidVocabularyLearned, _listGuidVocabularyLearned) &&
            (identical(other.countVocabulaireAll, countVocabulaireAll) ||
                other.countVocabulaireAll == countVocabulaireAll));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_listPerso),
      const DeepCollectionEquality().hash(_listTheme),
      const DeepCollectionEquality().hash(_listGuidVocabularyLearned),
      countVocabulaireAll);

  @override
  String toString() {
    return 'VocabulaireUser(listPerso: $listPerso, listTheme: $listTheme, listGuidVocabularyLearned: $listGuidVocabularyLearned, countVocabulaireAll: $countVocabulaireAll)';
  }
}

/// @nodoc
abstract mixin class _$VocabulaireUserCopyWith<$Res>
    implements $VocabulaireUserCopyWith<$Res> {
  factory _$VocabulaireUserCopyWith(
          _VocabulaireUser value, $Res Function(_VocabulaireUser) _then) =
      __$VocabulaireUserCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "ListPerso") List<ListPerso> listPerso,
      @JsonKey(name: "ListTheme") List<ListTheme> listTheme,
      @JsonKey(name: "ListGuidVocabularyLearned")
      List<String> listGuidVocabularyLearned,
      @JsonKey(name: "CountVocabulaireAll", defaultValue: 0)
      int countVocabulaireAll});
}

/// @nodoc
class __$VocabulaireUserCopyWithImpl<$Res>
    implements _$VocabulaireUserCopyWith<$Res> {
  __$VocabulaireUserCopyWithImpl(this._self, this._then);

  final _VocabulaireUser _self;
  final $Res Function(_VocabulaireUser) _then;

  /// Create a copy of VocabulaireUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? listPerso = null,
    Object? listTheme = null,
    Object? listGuidVocabularyLearned = null,
    Object? countVocabulaireAll = null,
  }) {
    return _then(_VocabulaireUser(
      listPerso: null == listPerso
          ? _self._listPerso
          : listPerso // ignore: cast_nullable_to_non_nullable
              as List<ListPerso>,
      listTheme: null == listTheme
          ? _self._listTheme
          : listTheme // ignore: cast_nullable_to_non_nullable
              as List<ListTheme>,
      listGuidVocabularyLearned: null == listGuidVocabularyLearned
          ? _self._listGuidVocabularyLearned
          : listGuidVocabularyLearned // ignore: cast_nullable_to_non_nullable
              as List<String>,
      countVocabulaireAll: null == countVocabulaireAll
          ? _self.countVocabulaireAll
          : countVocabulaireAll // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$ListPerso {
  @JsonKey(name: "guid")
  String get guid;
  @JsonKey(name: "title")
  String get title;
  @JsonKey(name: "color")
  int get color;
  @JsonKey(name: "listGuidVocabulary")
  List<String> get listGuidVocabulary;
  @JsonKey(name: "isListShare")
  bool get isListShare;
  @JsonKey(name: "ownListShare")
  bool get ownListShare;
  @JsonKey(name: "urlShare")
  String get urlShare;

  /// Create a copy of ListPerso
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ListPersoCopyWith<ListPerso> get copyWith =>
      _$ListPersoCopyWithImpl<ListPerso>(this as ListPerso, _$identity);

  /// Serializes this ListPerso to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ListPerso &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.color, color) || other.color == color) &&
            const DeepCollectionEquality()
                .equals(other.listGuidVocabulary, listGuidVocabulary) &&
            (identical(other.isListShare, isListShare) ||
                other.isListShare == isListShare) &&
            (identical(other.ownListShare, ownListShare) ||
                other.ownListShare == ownListShare) &&
            (identical(other.urlShare, urlShare) ||
                other.urlShare == urlShare));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      guid,
      title,
      color,
      const DeepCollectionEquality().hash(listGuidVocabulary),
      isListShare,
      ownListShare,
      urlShare);

  @override
  String toString() {
    return 'ListPerso(guid: $guid, title: $title, color: $color, listGuidVocabulary: $listGuidVocabulary, isListShare: $isListShare, ownListShare: $ownListShare, urlShare: $urlShare)';
  }
}

/// @nodoc
abstract mixin class $ListPersoCopyWith<$Res> {
  factory $ListPersoCopyWith(ListPerso value, $Res Function(ListPerso) _then) =
      _$ListPersoCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: "guid") String guid,
      @JsonKey(name: "title") String title,
      @JsonKey(name: "color") int color,
      @JsonKey(name: "listGuidVocabulary") List<String> listGuidVocabulary,
      @JsonKey(name: "isListShare") bool isListShare,
      @JsonKey(name: "ownListShare") bool ownListShare,
      @JsonKey(name: "urlShare") String urlShare});
}

/// @nodoc
class _$ListPersoCopyWithImpl<$Res> implements $ListPersoCopyWith<$Res> {
  _$ListPersoCopyWithImpl(this._self, this._then);

  final ListPerso _self;
  final $Res Function(ListPerso) _then;

  /// Create a copy of ListPerso
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guid = null,
    Object? title = null,
    Object? color = null,
    Object? listGuidVocabulary = null,
    Object? isListShare = null,
    Object? ownListShare = null,
    Object? urlShare = null,
  }) {
    return _then(_self.copyWith(
      guid: null == guid
          ? _self.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as int,
      listGuidVocabulary: null == listGuidVocabulary
          ? _self.listGuidVocabulary
          : listGuidVocabulary // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isListShare: null == isListShare
          ? _self.isListShare
          : isListShare // ignore: cast_nullable_to_non_nullable
              as bool,
      ownListShare: null == ownListShare
          ? _self.ownListShare
          : ownListShare // ignore: cast_nullable_to_non_nullable
              as bool,
      urlShare: null == urlShare
          ? _self.urlShare
          : urlShare // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ListPerso implements ListPerso {
  const _ListPerso(
      {@JsonKey(name: "guid") required this.guid,
      @JsonKey(name: "title") required this.title,
      @JsonKey(name: "color") required this.color,
      @JsonKey(name: "listGuidVocabulary")
      final List<String> listGuidVocabulary = const <String>[],
      @JsonKey(name: "isListShare") this.isListShare = true,
      @JsonKey(name: "ownListShare") this.ownListShare = true,
      @JsonKey(name: "urlShare") this.urlShare = 'ss'})
      : _listGuidVocabulary = listGuidVocabulary;
  factory _ListPerso.fromJson(Map<String, dynamic> json) =>
      _$ListPersoFromJson(json);

  @override
  @JsonKey(name: "guid")
  final String guid;
  @override
  @JsonKey(name: "title")
  final String title;
  @override
  @JsonKey(name: "color")
  final int color;
  final List<String> _listGuidVocabulary;
  @override
  @JsonKey(name: "listGuidVocabulary")
  List<String> get listGuidVocabulary {
    if (_listGuidVocabulary is EqualUnmodifiableListView)
      return _listGuidVocabulary;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_listGuidVocabulary);
  }

  @override
  @JsonKey(name: "isListShare")
  final bool isListShare;
  @override
  @JsonKey(name: "ownListShare")
  final bool ownListShare;
  @override
  @JsonKey(name: "urlShare")
  final String urlShare;

  /// Create a copy of ListPerso
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ListPersoCopyWith<_ListPerso> get copyWith =>
      __$ListPersoCopyWithImpl<_ListPerso>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ListPersoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ListPerso &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.color, color) || other.color == color) &&
            const DeepCollectionEquality()
                .equals(other._listGuidVocabulary, _listGuidVocabulary) &&
            (identical(other.isListShare, isListShare) ||
                other.isListShare == isListShare) &&
            (identical(other.ownListShare, ownListShare) ||
                other.ownListShare == ownListShare) &&
            (identical(other.urlShare, urlShare) ||
                other.urlShare == urlShare));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      guid,
      title,
      color,
      const DeepCollectionEquality().hash(_listGuidVocabulary),
      isListShare,
      ownListShare,
      urlShare);

  @override
  String toString() {
    return 'ListPerso(guid: $guid, title: $title, color: $color, listGuidVocabulary: $listGuidVocabulary, isListShare: $isListShare, ownListShare: $ownListShare, urlShare: $urlShare)';
  }
}

/// @nodoc
abstract mixin class _$ListPersoCopyWith<$Res>
    implements $ListPersoCopyWith<$Res> {
  factory _$ListPersoCopyWith(
          _ListPerso value, $Res Function(_ListPerso) _then) =
      __$ListPersoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "guid") String guid,
      @JsonKey(name: "title") String title,
      @JsonKey(name: "color") int color,
      @JsonKey(name: "listGuidVocabulary") List<String> listGuidVocabulary,
      @JsonKey(name: "isListShare") bool isListShare,
      @JsonKey(name: "ownListShare") bool ownListShare,
      @JsonKey(name: "urlShare") String urlShare});
}

/// @nodoc
class __$ListPersoCopyWithImpl<$Res> implements _$ListPersoCopyWith<$Res> {
  __$ListPersoCopyWithImpl(this._self, this._then);

  final _ListPerso _self;
  final $Res Function(_ListPerso) _then;

  /// Create a copy of ListPerso
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? guid = null,
    Object? title = null,
    Object? color = null,
    Object? listGuidVocabulary = null,
    Object? isListShare = null,
    Object? ownListShare = null,
    Object? urlShare = null,
  }) {
    return _then(_ListPerso(
      guid: null == guid
          ? _self.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as int,
      listGuidVocabulary: null == listGuidVocabulary
          ? _self._listGuidVocabulary
          : listGuidVocabulary // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isListShare: null == isListShare
          ? _self.isListShare
          : isListShare // ignore: cast_nullable_to_non_nullable
              as bool,
      ownListShare: null == ownListShare
          ? _self.ownListShare
          : ownListShare // ignore: cast_nullable_to_non_nullable
              as bool,
      urlShare: null == urlShare
          ? _self.urlShare
          : urlShare // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$ListTheme {
  @JsonKey(name: "guid")
  String get guid;
  @JsonKey(name: "title")
  String get title;
  @JsonKey(name: "color")
  String get color;
  @JsonKey(name: "listGuidVocabulary")
  List<String> get listGuidVocabulary;

  /// Create a copy of ListTheme
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ListThemeCopyWith<ListTheme> get copyWith =>
      _$ListThemeCopyWithImpl<ListTheme>(this as ListTheme, _$identity);

  /// Serializes this ListTheme to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ListTheme &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.color, color) || other.color == color) &&
            const DeepCollectionEquality()
                .equals(other.listGuidVocabulary, listGuidVocabulary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, guid, title, color,
      const DeepCollectionEquality().hash(listGuidVocabulary));

  @override
  String toString() {
    return 'ListTheme(guid: $guid, title: $title, color: $color, listGuidVocabulary: $listGuidVocabulary)';
  }
}

/// @nodoc
abstract mixin class $ListThemeCopyWith<$Res> {
  factory $ListThemeCopyWith(ListTheme value, $Res Function(ListTheme) _then) =
      _$ListThemeCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: "guid") String guid,
      @JsonKey(name: "title") String title,
      @JsonKey(name: "color") String color,
      @JsonKey(name: "listGuidVocabulary") List<String> listGuidVocabulary});
}

/// @nodoc
class _$ListThemeCopyWithImpl<$Res> implements $ListThemeCopyWith<$Res> {
  _$ListThemeCopyWithImpl(this._self, this._then);

  final ListTheme _self;
  final $Res Function(ListTheme) _then;

  /// Create a copy of ListTheme
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? guid = null,
    Object? title = null,
    Object? color = null,
    Object? listGuidVocabulary = null,
  }) {
    return _then(_self.copyWith(
      guid: null == guid
          ? _self.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      listGuidVocabulary: null == listGuidVocabulary
          ? _self.listGuidVocabulary
          : listGuidVocabulary // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ListTheme implements ListTheme {
  const _ListTheme(
      {@JsonKey(name: "guid") required this.guid,
      @JsonKey(name: "title") required this.title,
      @JsonKey(name: "color") required this.color,
      @JsonKey(name: "listGuidVocabulary")
      required final List<String> listGuidVocabulary})
      : _listGuidVocabulary = listGuidVocabulary;
  factory _ListTheme.fromJson(Map<String, dynamic> json) =>
      _$ListThemeFromJson(json);

  @override
  @JsonKey(name: "guid")
  final String guid;
  @override
  @JsonKey(name: "title")
  final String title;
  @override
  @JsonKey(name: "color")
  final String color;
  final List<String> _listGuidVocabulary;
  @override
  @JsonKey(name: "listGuidVocabulary")
  List<String> get listGuidVocabulary {
    if (_listGuidVocabulary is EqualUnmodifiableListView)
      return _listGuidVocabulary;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_listGuidVocabulary);
  }

  /// Create a copy of ListTheme
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ListThemeCopyWith<_ListTheme> get copyWith =>
      __$ListThemeCopyWithImpl<_ListTheme>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ListThemeToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ListTheme &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.color, color) || other.color == color) &&
            const DeepCollectionEquality()
                .equals(other._listGuidVocabulary, _listGuidVocabulary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, guid, title, color,
      const DeepCollectionEquality().hash(_listGuidVocabulary));

  @override
  String toString() {
    return 'ListTheme(guid: $guid, title: $title, color: $color, listGuidVocabulary: $listGuidVocabulary)';
  }
}

/// @nodoc
abstract mixin class _$ListThemeCopyWith<$Res>
    implements $ListThemeCopyWith<$Res> {
  factory _$ListThemeCopyWith(
          _ListTheme value, $Res Function(_ListTheme) _then) =
      __$ListThemeCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "guid") String guid,
      @JsonKey(name: "title") String title,
      @JsonKey(name: "color") String color,
      @JsonKey(name: "listGuidVocabulary") List<String> listGuidVocabulary});
}

/// @nodoc
class __$ListThemeCopyWithImpl<$Res> implements _$ListThemeCopyWith<$Res> {
  __$ListThemeCopyWithImpl(this._self, this._then);

  final _ListTheme _self;
  final $Res Function(_ListTheme) _then;

  /// Create a copy of ListTheme
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? guid = null,
    Object? title = null,
    Object? color = null,
    Object? listGuidVocabulary = null,
  }) {
    return _then(_ListTheme(
      guid: null == guid
          ? _self.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      listGuidVocabulary: null == listGuidVocabulary
          ? _self._listGuidVocabulary
          : listGuidVocabulary // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

// dart format on
