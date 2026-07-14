/// 소통웨어(SotongWare) 관련 외부 프로모션 사이트 링크 모음.
///
/// '소통웨어 소개' 페이지 등에서 참조하는 외부 링크를 한 곳에서 관리한다.
class ExternalLinks {
  ExternalLinks._();

  static const String sotongwareControl = 'https://sotongware.com/control';
  static const String sotongwareAutomation =
      'https://sotongware.com/automation';
  static const String sotongwareApps = 'https://sotongware.com/apps';
  static const String sotongwareEbook = 'https://sotongware.com/ebook';
  static const String sotongwareContents = 'https://sotongware.com/contents';

  /// '소통웨어 소개' 페이지에서 카드 형태로 노출할 사업 영역 목록.
  static const List<ExternalLinkItem> businessAreas = [
    ExternalLinkItem(
      title: '스마트 제어 솔루션',
      description: 'IoT 기반 원격 제어 및 자동화 하드웨어·소프트웨어 솔루션을 제공합니다.',
      url: sotongwareControl,
    ),
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
