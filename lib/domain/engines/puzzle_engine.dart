// Logic puzzle murni (tanpa Flutter) supaya gampang di-unit-test.

/// Hasil evaluasi satu ruangan.
class PuzzleResult {
  final bool isSuccess;
  final int score;
  final int stars;
  final String feedback;

  const PuzzleResult({
    required this.isSuccess,
    required this.score,
    required this.stars,
    required this.feedback,
  });
}

/// Skor ruangan: base − penalti petunjuk − penalti jawaban salah.
/// Tidak ada bonus waktu: escape room ini santai, tanpa countdown.
abstract class ScoreCalculator {
  static const baseScore = 100;
  static const hintPenalty = 25;
  static const wrongAttemptPenalty = 10;

  static int score({
    required int hintsUsed,
    required int wrongAttempts,
    int base = baseScore,
  }) {
    final penalty = hintsUsed * hintPenalty + wrongAttempts * wrongAttemptPenalty;
    return (base - penalty).clamp(base ~/ 2, base);
  }

  static int stars({required int hintsUsed, required int wrongAttempts}) {
    if (hintsUsed == 0 && wrongAttempts <= 1) return 3;
    if (hintsUsed <= 1 && wrongAttempts <= 3) return 2;
    return 1;
  }

  static PuzzleResult success({
    required int hintsUsed,
    required int wrongAttempts,
    required String feedback,
    int base = baseScore,
  }) =>
      PuzzleResult(
        isSuccess: true,
        score: score(hintsUsed: hintsUsed, wrongAttempts: wrongAttempts, base: base),
        stars: stars(hintsUsed: hintsUsed, wrongAttempts: wrongAttempts),
        feedback: feedback,
      );
}

/// Caesar cipher — Ruang 10 (Cyber Security).
abstract class CipherEngine {
  static String shift(String text, int shift) {
    final buffer = StringBuffer();
    for (final rune in text.toUpperCase().runes) {
      if (rune >= 65 && rune <= 90) {
        final moved = ((rune - 65 + shift) % 26 + 26) % 26;
        buffer.writeCharCode(65 + moved);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  /// Decode = geser balik.
  static String decode(String cipherText, int shift) => CipherEngine.shift(cipherText, -shift);
}
