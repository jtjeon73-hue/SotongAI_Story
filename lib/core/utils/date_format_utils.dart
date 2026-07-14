import 'package:intl/intl.dart';

/// 날짜 관련 표시 포맷팅 헬퍼.
class DateFormatUtils {
  DateFormatUtils._();

  static final DateFormat _yMd = DateFormat('yyyy년 M월 d일');
  static final DateFormat _ym = DateFormat('yyyy년 M월');

  /// `yyyy-MM-dd` 또는 `yyyy-MM` 형식의 문자열을 한국어 표기로 변환한다.
  ///
  /// 파싱에 실패하면 원본 문자열을 그대로 반환한다.
  static String formatKoreanDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '검증일 미확인';
    try {
      final parts = isoDate.split('-');
      if (parts.length == 3) {
        final date = DateTime.parse(isoDate);
        return _yMd.format(date);
      } else if (parts.length == 2) {
        final date = DateTime.parse('$isoDate-01');
        return _ym.format(date);
      }
      return isoDate;
    } catch (_) {
      return isoDate;
    }
  }

  /// '최근 검증: yyyy년 M월 d일' 형태의 문구를 생성한다.
  static String verifiedLabel(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '검증일 미확인';
    return '최근 검증: ${formatKoreanDate(isoDate)}';
  }
}
