/// 특정 라우트에 대해 적용할 SEO 메타데이터.
///
/// 플랫폼 구현(`dart:html`/스텁)에 공통으로 전달되는 순수 데이터 클래스라서
/// `dart:html`을 임포트하지 않는다. 이 파일은 웹/비웹 양쪽에서 그대로
/// 사용할 수 있다.
class SeoMetaInfo {
  const SeoMetaInfo({
    required this.title,
    required this.description,
    required this.canonicalUrl,
    this.noIndex = false,
  });

  /// `document.title`과 `og:title`/`twitter:title`에 사용할 제목.
  final String title;

  /// `meta[name=description]`과 `og:description`에 사용할 설명.
  final String description;

  /// `link[rel=canonical]`과 `og:url`에 사용할 절대 URL.
  final String canonicalUrl;

  /// true면 `meta[name=robots]`를 `noindex, nofollow`로 설정한다.
  final bool noIndex;
}
