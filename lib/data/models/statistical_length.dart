import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistical_length.freezed.dart';
part 'statistical_length.g.dart';

@Freezed() // <--- C'est cette majuscule qui est essentielle !
abstract class StatisticalLength with _$StatisticalLength {
  const factory StatisticalLength({
    required int vocabLearnedCount,
    required int countVocabulaireAll,
  }) = _StatisticalLength;

  factory StatisticalLength.fromJson(Map<String, dynamic> json) =>
      _$StatisticalLengthFromJson(json);
}
