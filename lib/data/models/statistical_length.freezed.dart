// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'statistical_length.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StatisticalLength {
  int get vocabLearnedCount;
  int get countVocabulaireAll;

  /// Create a copy of StatisticalLength
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StatisticalLengthCopyWith<StatisticalLength> get copyWith =>
      _$StatisticalLengthCopyWithImpl<StatisticalLength>(
          this as StatisticalLength, _$identity);

  /// Serializes this StatisticalLength to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StatisticalLength &&
            (identical(other.vocabLearnedCount, vocabLearnedCount) ||
                other.vocabLearnedCount == vocabLearnedCount) &&
            (identical(other.countVocabulaireAll, countVocabulaireAll) ||
                other.countVocabulaireAll == countVocabulaireAll));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, vocabLearnedCount, countVocabulaireAll);

  @override
  String toString() {
    return 'StatisticalLength(vocabLearnedCount: $vocabLearnedCount, countVocabulaireAll: $countVocabulaireAll)';
  }
}

/// @nodoc
abstract mixin class $StatisticalLengthCopyWith<$Res> {
  factory $StatisticalLengthCopyWith(
          StatisticalLength value, $Res Function(StatisticalLength) _then) =
      _$StatisticalLengthCopyWithImpl;
  @useResult
  $Res call({int vocabLearnedCount, int countVocabulaireAll});
}

/// @nodoc
class _$StatisticalLengthCopyWithImpl<$Res>
    implements $StatisticalLengthCopyWith<$Res> {
  _$StatisticalLengthCopyWithImpl(this._self, this._then);

  final StatisticalLength _self;
  final $Res Function(StatisticalLength) _then;

  /// Create a copy of StatisticalLength
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vocabLearnedCount = null,
    Object? countVocabulaireAll = null,
  }) {
    return _then(_self.copyWith(
      vocabLearnedCount: null == vocabLearnedCount
          ? _self.vocabLearnedCount
          : vocabLearnedCount // ignore: cast_nullable_to_non_nullable
              as int,
      countVocabulaireAll: null == countVocabulaireAll
          ? _self.countVocabulaireAll
          : countVocabulaireAll // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _StatisticalLength implements StatisticalLength {
  const _StatisticalLength(
      {required this.vocabLearnedCount, required this.countVocabulaireAll});
  factory _StatisticalLength.fromJson(Map<String, dynamic> json) =>
      _$StatisticalLengthFromJson(json);

  @override
  final int vocabLearnedCount;
  @override
  final int countVocabulaireAll;

  /// Create a copy of StatisticalLength
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StatisticalLengthCopyWith<_StatisticalLength> get copyWith =>
      __$StatisticalLengthCopyWithImpl<_StatisticalLength>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StatisticalLengthToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StatisticalLength &&
            (identical(other.vocabLearnedCount, vocabLearnedCount) ||
                other.vocabLearnedCount == vocabLearnedCount) &&
            (identical(other.countVocabulaireAll, countVocabulaireAll) ||
                other.countVocabulaireAll == countVocabulaireAll));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, vocabLearnedCount, countVocabulaireAll);

  @override
  String toString() {
    return 'StatisticalLength(vocabLearnedCount: $vocabLearnedCount, countVocabulaireAll: $countVocabulaireAll)';
  }
}

/// @nodoc
abstract mixin class _$StatisticalLengthCopyWith<$Res>
    implements $StatisticalLengthCopyWith<$Res> {
  factory _$StatisticalLengthCopyWith(
          _StatisticalLength value, $Res Function(_StatisticalLength) _then) =
      __$StatisticalLengthCopyWithImpl;
  @override
  @useResult
  $Res call({int vocabLearnedCount, int countVocabulaireAll});
}

/// @nodoc
class __$StatisticalLengthCopyWithImpl<$Res>
    implements _$StatisticalLengthCopyWith<$Res> {
  __$StatisticalLengthCopyWithImpl(this._self, this._then);

  final _StatisticalLength _self;
  final $Res Function(_StatisticalLength) _then;

  /// Create a copy of StatisticalLength
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? vocabLearnedCount = null,
    Object? countVocabulaireAll = null,
  }) {
    return _then(_StatisticalLength(
      vocabLearnedCount: null == vocabLearnedCount
          ? _self.vocabLearnedCount
          : vocabLearnedCount // ignore: cast_nullable_to_non_nullable
              as int,
      countVocabulaireAll: null == countVocabulaireAll
          ? _self.countVocabulaireAll
          : countVocabulaireAll // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
