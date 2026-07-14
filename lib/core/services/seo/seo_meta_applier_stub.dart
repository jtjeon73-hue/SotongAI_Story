import 'seo_meta_info.dart';

/// 비웹(모바일/데스크톱) 플랫폼에서는 `document`가 없으므로 아무 작업도
/// 하지 않는 스텁 구현.
void applySeoMeta(SeoMetaInfo info) {
  // 웹이 아닌 플랫폼에서는 HTML 메타 태그가 존재하지 않으므로 무시한다.
}
