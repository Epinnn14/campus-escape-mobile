import 'package:campus_escape/domain/engines/puzzle_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SequenceEvaluator', () {
    const answer = ['A', 'B', 'C'];

    test('incomplete when a slot is empty', () {
      expect(
        SequenceEvaluator.check(placed: ['A', '', 'C'], answer: answer),
        SequenceCheck.incomplete,
      );
    });

    test('wrong when order differs', () {
      expect(
        SequenceEvaluator.check(placed: ['A', 'C', 'B'], answer: answer),
        SequenceCheck.wrong,
      );
      expect(
        SequenceEvaluator.firstMismatch(placed: ['A', 'C', 'B'], answer: answer),
        1,
      );
    });

    test('correct when identical', () {
      expect(
        SequenceEvaluator.check(placed: ['A', 'B', 'C'], answer: answer),
        SequenceCheck.correct,
      );
    });
  });

  group('ScoreCalculator', () {
    test('full score without penalties', () {
      expect(ScoreCalculator.score(hintsUsed: 0, wrongAttempts: 0, base: 200), 200);
    });

    test('hints and wrong attempts reduce score but never below half base', () {
      expect(ScoreCalculator.score(hintsUsed: 1, wrongAttempts: 2, base: 200), 155);
      expect(ScoreCalculator.score(hintsUsed: 5, wrongAttempts: 10, base: 200), 100);
    });

    test('stars follow hints/wrong attempts', () {
      expect(ScoreCalculator.stars(hintsUsed: 0, wrongAttempts: 0), 3);
      expect(ScoreCalculator.stars(hintsUsed: 1, wrongAttempts: 2), 2);
      expect(ScoreCalculator.stars(hintsUsed: 2, wrongAttempts: 0), 1);
    });
  });

  group('CipherEngine', () {
    test('decodes Caesar shift 3', () {
      expect(CipherEngine.decode('FDPSXV', 3), 'CAMPUS');
      expect(CipherEngine.shift('CAMPUS', 3), 'FDPSXV');
    });

    test('wraps around the alphabet', () {
      expect(CipherEngine.shift('XYZ', 3), 'ABC');
      expect(CipherEngine.decode('ABC', 3), 'XYZ');
    });
  });
}
