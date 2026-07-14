/// 검색어 정규화: 앞뒤 공백을 제거하고, 내부의 연속 공백을 하나로 합치고,
/// 소문자로 변환한다. 대소문자·다중 공백 차이로 검색이 실패하지 않도록 한다.
String normalizeSearchQuery(String raw) {
  return raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

/// 한글 문자열에서 초성만 추출한다(예: "챗지피티" → "ㅊㅈㅍㅌ").
///
/// 완성형 한글(가~힣) 음절에서만 초성을 추출하며, 영문/숫자/기타 문자는
/// 그대로 유지한다. 자모 분해 데이터를 크게 늘리지 않기 위해 초성 19개만
/// 다루는 가벼운 구현으로, 완전한 한글 자모 분석기를 대체하지는 않는다.
String extractChosung(String input) {
  const chosungList = [
    'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅂㅂ', 'ㅅ',
    'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
  ];
  const hangulBase = 0xAC00;
  const hangulLast = 0xD7A3;
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= hangulBase && rune <= hangulLast) {
      final index = (rune - hangulBase) ~/ (21 * 28);
      buffer.write(chosungList[index]);
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

/// 검색어가 순수 초성(ㄱ~ㅎ)만으로 구성되어 있는지 확인한다.
bool isChosungOnlyQuery(String query) {
  if (query.isEmpty) return false;
  final chosungRange = RegExp(r'^[ㄱ-ㅎ\s]+$');
  return chosungRange.hasMatch(query);
}

/// [target] 문자열의 초성이 초성 검색어 [chosungQuery]를 포함하는지 확인한다.
///
/// 예: `matchesChosung("챗지피티", "ㅊㅍ")` → 초성 "ㅊㅈㅍㅌ"에 "ㅊㅈㅍㅌ"의
/// 부분 문자열로 "ㅊㅍ"이 직접 포함되지는 않으므로 순서를 지키는 부분열
/// (subsequence) 매칭을 사용해 유연하게 비교한다.
bool matchesChosung(String target, String chosungQuery) {
  final targetChosung = extractChosung(target);
  var qi = 0;
  for (var i = 0; i < targetChosung.length && qi < chosungQuery.length; i++) {
    if (targetChosung[i] == chosungQuery[qi]) qi++;
  }
  return qi == chosungQuery.length;
}
