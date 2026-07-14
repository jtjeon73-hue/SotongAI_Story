import 'package:web/web.dart' as web;

import 'seo_meta_info.dart';

/// 웹 플랫폼에서 `document.title`과 주요 메타 태그를 [info]에 맞게 갱신한다.
///
/// go_router로 클라이언트 사이드 내비게이션을 할 때는 `index.html`이
/// 다시 로드되지 않으므로, 페이지가 바뀔 때마다 이 함수를 호출해 제목과
/// 메타 태그를 최신 상태로 맞춰야 검색엔진/공유 미리보기가 정확해진다.
/// (검색엔진 크롤러용 정적 메타 태그는 `tool/generate_seo_pages.dart`가
/// 빌드 시점에 별도로 생성한다.)
void applySeoMeta(SeoMetaInfo info) {
  web.document.title = info.title;

  _setMetaByName('description', info.description);
  _setMetaByName('robots', info.noIndex ? 'noindex, nofollow' : 'index, follow');
  _setLinkCanonical(info.canonicalUrl);

  _setMetaByProperty('og:title', info.title);
  _setMetaByProperty('og:description', info.description);
  _setMetaByProperty('og:url', info.canonicalUrl);

  _setMetaByName('twitter:title', info.title);
  _setMetaByName('twitter:description', info.description);
}

void _setMetaByName(String name, String content) {
  final existing = web.document.querySelector('meta[name="$name"]');
  if (existing != null) {
    existing.setAttribute('content', content);
    return;
  }
  final meta = web.document.createElement('meta') as web.HTMLMetaElement
    ..name = name
    ..content = content;
  web.document.head?.append(meta);
}

void _setMetaByProperty(String property, String content) {
  final existing = web.document.querySelector('meta[property="$property"]');
  if (existing != null) {
    existing.setAttribute('content', content);
    return;
  }
  final meta = web.document.createElement('meta') as web.HTMLMetaElement
    ..setAttribute('property', property)
    ..content = content;
  web.document.head?.append(meta);
}

void _setLinkCanonical(String href) {
  final existing = web.document.querySelector('link[rel="canonical"]');
  if (existing != null) {
    existing.setAttribute('href', href);
    return;
  }
  final link = web.document.createElement('link') as web.HTMLLinkElement
    ..rel = 'canonical'
    ..href = href;
  web.document.head?.append(link);
}
