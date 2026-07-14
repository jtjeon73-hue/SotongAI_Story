/// 소통웨어(SotongWare) 관련 외부 프로모션 사이트 링크 모음.
///
/// '소통웨어 소개' 페이지 등에서 참조하는 외부 링크를 한 곳에서 관리한다.
///
/// 아래 4개 Firebase 프로모션 링크만 공개 노출한다(HTTP 200 확인됨).
/// 내부 관제·제어용 사이트 URL은 공개 관련 링크로 포함하지 않는다.
class ExternalLinks {
  ExternalLinks._();

  static const String sotongwareAutomation =
      'https://sotong-automation-promo.web.app';
  static const String sotongwareApps = 'https://sotongware-apps-promo.web.app';
  static const String sotongwareEbook =
      'https://sotongware-ebook-promo.web.app';
  static const String sotongwareContents =
      'https://sotongware-contents-promo.web.app';

  /// '소통웨어 소개' 페이지에서 카드 형태로 노출할 사업 영역 목록(4개).
  static const List<ExternalLinkItem> businessAreas = [
    ExternalLinkItem(
      title: '업무 자동화',
      description: '반복 업무를 줄여주는 자동화 워크플로우 구축 서비스를 제공합니다.',
      url: sotongwareAutomation,
    ),
    ExternalLinkItem(
      title: '자체 애플리케이션',
      description: '소통웨어가 직접 기획·개발한 다양한 모바일·웹 애플리케이션입니다.',
      url: sotongwareApps,
    ),
    ExternalLinkItem(
      title: '전자책(E-book)',
      description: 'AI와 기술 트렌드를 다루는 소통웨어의 전자책 콘텐츠입니다.',
      url: sotongwareEbook,
    ),
    ExternalLinkItem(
      title: '콘텐츠 제작',
      description: '블로그, 영상 등 다양한 형태의 디지털 콘텐츠를 제작합니다.',
      url: sotongwareContents,
    ),
  ];
}

/// 외부 링크 카드 표시용 불변 데이터 클래스.
class ExternalLinkItem {
  const ExternalLinkItem({
    required this.title,
    required this.description,
    required this.url,
  });

  final String title;
  final String description;
  final String url;
}
