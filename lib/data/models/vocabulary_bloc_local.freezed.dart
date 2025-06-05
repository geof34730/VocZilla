// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vocabulary_bloc_local.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VocabularyBlocLocal {
  String get titleList;
  List<dynamic> get vocabulaireList;
  int get dataAllLength;
  int? get vocabulaireBegin;
  int? get vocabulaireEnd;
  bool get isListPerso;
  bool get isListTheme;
  String? get guid;
  bool get isVocabularyNotLearned;

  /// Create a copy of VocabularyBlocLocal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VocabularyBlocLocalCopyWith<VocabularyBlocLocal> get copyWith =>
      _$VocabularyBlocLocalCopyWithImpl<VocabularyBlocLocal>(
          this as VocabularyBlocLocal, _$identity);

  /// Serializes this VocabularyBlocLocal to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VocabularyBlocLocal &&
            (identical(other.titleList, titleList) ||
                other.titleList == titleList) &&
            const DeepCollectionEquality()
                .equals(other.vocabulaireList, vocabulaireList) &&
            (identical(other.dataAllLength, dataAllLength) ||
                other.dataAllLength == dataAllLength) &&
            (identical(other.vocabulaireBegin, vocabulaireBegin) ||
                other.vocabulaireBegin == vocabulaireBegin) &&
            (identical(other.vocabulaireEnd, vocabulaireEnd) ||
                other.vocabulaireEnd == vocabulaireEnd) &&
            (identical(other.isListPerso, isListPerso) ||
                other.isListPerso == isListPerso) &&
            (identical(other.isListTheme, isListTheme) ||
                other.isListTheme == isListTheme) &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.isVocabularyNotLearned, isVocabularyNotLearned) ||
                other.isVocabularyNotLearned == isVocabularyNotLearned));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      titleList,
      const DeepCollectionEquality().hash(vocabulaireList),
      dataAllLength,
      vocabulaireBegin,
      vocabulaireEnd,
      isListPerso,
      isListTheme,
      guid,
      isVocabularyNotLearned);

  @override
  String toString() {
    return 'VocabularyBlocLocal(titleList: $titleList, vocabulaireList: $vocabulaireList, dataAllLength: $dataAllLength, vocabulaireBegin: $vocabulaireBegin, vocabulaireEnd: $vocabulaireEnd, isListPerso: $isListPerso, isListTheme: $isListTheme, guid: $guid, isVocabularyNotLearned: $isVocabularyNotLearned)';
  }
}

/// @nodoc
abstract mixin class $VocabularyBlocLocalCopyWith<$Res> {
  factory $VocabularyBlocLocalCopyWith(
          VocabularyBlocLocal value, $Res Function(VocabularyBlocLocal) _then) =
      _$VocabularyBlocLocalCopyWithImpl;
  @useResult
  $Res call(
      {String titleList,
      List<dynamic> vocabulaireList,
      int dataAllLength,
      int? vocabulaireBegin,
      int? vocabulaireEnd,
      bool isListPerso,
      bool isListTheme,
      String? guid,
      bool isVocabularyNotLearned});
}

/// @nodoc
class _$VocabularyBlocLocalCopyWithImpl<$Res>
    implements $VocabularyBlocLocalCopyWith<$Res> {
  _$VocabularyBlocLocalCopyWithImpl(this._self, this._then);

  final VocabularyBlocLocal _self;
  final $Res Function(VocabularyBlocLocal) _then;

  /// Create a copy of VocabularyBlocLocal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? titleList = null,
    Object? vocabulaireList = null,
    Object? dataAllLength = null,
    Object? vocabulaireBegin = freezed,
    Object? vocabulaireEnd = freezed,
    Object? isListPerso = null,
    Object? isListTheme = null,
    Object? guid = freezed,
    Object? isVocabularyNotLearned = null,
  }) {
    return _then(_self.copyWith(
      titleList: null == titleList
          ? _self.titleList
          : titleList // ignore: cast_nullable_to_non_nullable
              as String,
      vocabulaireList: null == vocabulaireList
          ? _self.vocabulaireList
          : vocabulaireList // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      dataAllLength: null == dataAllLength
          ? _self.dataAllLength
          : dataAllLength // ignore: cast_nullable_to_non_nullable
              as int,
      vocabulaireBegin: freezed == vocabulaireBegin
          ? _self.vocabulaireBegin
          : vocabulaireBegin // ignore: cast_nullable_to_non_nullable
              as int?,
      vocabulaireEnd: freezed == vocabulaireEnd
          ? _self.vocabulaireEnd
          : vocabulaireEnd // ignore: cast_nullable_to_non_nullable
              as int?,
      isListPerso: null == isListPerso
          ? _self.isListPerso
          : isListPerso // ignore: cast_nullable_to_non_nullable
              as bool,
      isListTheme: null == isListTheme
          ? _self.isListTheme
          : isListTheme // ignore: cast_nullable_to_non_nullable
              as bool,
      guid: freezed == guid
          ? _self.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String?,
      isVocabularyNotLearned: null == isVocabularyNotLearned
          ? _self.isVocabularyNotLearned
          : isVocabularyNotLearned // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _VocabularyBlocLocal implements VocabularyBlocLocal {
  const _VocabularyBlocLocal(
      {required this.titleList,
      required final List<dynamic> vocabulaireList,
      required this.dataAllLength,
      this.vocabulaireBegin,
      this.vocabulaireEnd,
      required this.isListPerso,
      required this.isListTheme,
      this.guid,
      required this.isVocabularyNotLearned})
      : _vocabulaireList = vocabulaireList;
  factory _VocabularyBlocLocal.fromJson(Map<String, dynamic> json) =>
      _$VocabularyBlocLocalFromJson(json);

  @override
  final String titleList;
  final List<dynamic> _vocabulaireList;
  @override
  List<dynamic> get vocabulaireList {
    if (_vocabulaireList is EqualUnmodifiableListView) return _vocabulaireList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_vocabulaireList);
  }

  @override
  final int dataAllLength;
  @override
  final int? vocabulaireBegin;
  @override
  final int? vocabulaireEnd;
  @override
  final bool isListPerso;
  @override
  final bool isListTheme;
  @override
  final String? guid;
  @override
  final bool isVocabularyNotLearned;

  /// Create a copy of VocabularyBlocLocal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$VocabularyBlocLocalCopyWith<_VocabularyBlocLocal> get copyWith =>
      __$VocabularyBlocLocalCopyWithImpl<_VocabularyBlocLocal>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$VocabularyBlocLocalToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _VocabularyBlocLocal &&
            (identical(other.titleList, titleList) ||
                other.titleList == titleList) &&
            const DeepCollectionEquality()
                .equals(other._vocabulaireList, _vocabulaireList) &&
            (identical(other.dataAllLength, dataAllLength) ||
                other.dataAllLength == dataAllLength) &&
            (identical(other.vocabulaireBegin, vocabulaireBegin) ||
                other.vocabulaireBegin == vocabulaireBegin) &&
            (identical(other.vocabulaireEnd, vocabulaireEnd) ||
                other.vocabulaireEnd == vocabulaireEnd) &&
            (identical(other.isListPerso, isListPerso) ||
                other.isListPerso == isListPerso) &&
            (identical(other.isListTheme, isListTheme) ||
                other.isListTheme == isListTheme) &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.isVocabularyNotLearned, isVocabularyNotLearned) ||
                other.isVocabularyNotLearned == isVocabularyNotLearned));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      titleList,
      const DeepCollectionEquality().hash(_vocabulaireList),
      dataAllLength,
      vocabulaireBegin,
      vocabulaireEnd,
      isListPerso,
      isListTheme,
      guid,
      isVocabularyNotLearned);

  @override
  String toString() {
    return 'VocabularyBlocLocal(titleList: $titleList, vocabulaireList: $vocabulaireList, dataAllLength: $dataAllLength, vocabulaireBegin: $vocabulaireBegin, vocabulaireEnd: $vocabulaireEnd, isListPerso: $isListPerso, isListTheme: $isListTheme, guid: $guid, isVocabularyNotLearned: $isVocabularyNotLearned)';
  }
}

/// @nodoc
abstract mixin class _$VocabularyBlocLocalCopyWith<$Res>
    implements $VocabularyBlocLocalCopyWith<$Res> {
  factory _$VocabularyBlocLocalCopyWith(_VocabularyBlocLocal value,
          $Res Function(_VocabularyBlocLocal) _then) =
      __$VocabularyBlocLocalCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String titleList,
      List<dynamic> vocabulaireList,
      int dataAllLength,
      int? vocabulaireBegin,
      int? vocabulaireEnd,
      bool isListPerso,
      bool isListTheme,
      String? guid,
      bool isVocabularyNotLearned});
}

/// @nodoc
class __$VocabularyBlocLocalCopyWithImpl<$Res>
    implements _$VocabularyBlocLocalCopyWith<$Res> {
  __$VocabularyBlocLocalCopyWithImpl(this._self, this._then);

  final _VocabularyBlocLocal _self;
  final $Res Function(_VocabularyBlocLocal) _then;

  /// Create a copy of VocabularyBlocLocal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? titleList = null,
    Object? vocabulaireList = null,
    Object? dataAllLength = null,
    Object? vocabulaireBegin = freezed,
    Object? vocabulaireEnd = freezed,
    Object? isListPerso = null,
    Object? isListTheme = null,
    Object? guid = freezed,
    Object? isVocabularyNotLearned = null,
  }) {
    return _then(_VocabularyBlocLocal(
      titleList: null == titleList
          ? _self.titleList
          : titleList // ignore: cast_nullable_to_non_nullable
              as String,
      vocabulaireList: null == vocabulaireList
          ? _self._vocabulaireList
          : vocabulaireList // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      dataAllLength: null == dataAllLength
          ? _self.dataAllLength
          : dataAllLength // ignore: cast_nullable_to_non_nullable
              as int,
      vocabulaireBegin: freezed == vocabulaireBegin
          ? _self.vocabulaireBegin
          : vocabulaireBegin // ignore: cast_nullable_to_non_nullable
              as int?,
      vocabulaireEnd: freezed == vocabulaireEnd
          ? _self.vocabulaireEnd
          : vocabulaireEnd // ignore: cast_nullable_to_non_nullable
              as int?,
      isListPerso: null == isListPerso
          ? _self.isListPerso
          : isListPerso // ignore: cast_nullable_to_non_nullable
              as bool,
      isListTheme: null == isListTheme
          ? _self.isListTheme
          : isListTheme // ignore: cast_nullable_to_non_nullable
              as bool,
      guid: freezed == guid
          ? _self.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String?,
      isVocabularyNotLearned: null == isVocabularyNotLearned
          ? _self.isVocabularyNotLearned
          : isVocabularyNotLearned // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
