// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// `assets/data/*.json`을 읽어 `sitemap.xml`을 생성하는 독립 실행 스크립트.
///
/// 실행:
/// - `dart run tool/generate_sitemap.dart` → `web/sitemap.xml`에 생성
///   (Flutter 웹 빌드에 포함되도록 소스 트리의 `web/` 폴더에 둔다)
/// - `dart run tool/generate_sitemap.dart --out=build/web` → 빌드 완료 뒤
///   `build/web/sitemap.xml`에 다시 생성(가장 최신 데이터 기준으로 배포
///   직전에 한 번 더 실행하고 싶을 때 사용)
///
/// 포함하는 URL:
/// - 최상위 메뉴 경로 전체(검색/즐겨찾기 등 개인화 경로는 제외)
/// - 연대표/시대/핵심개념/AI툴/활용사례/워크플로 상세 경로(각 JSON의 `id` 기준)
///
/// `lastmod`는 항목별 `verifiedAt`/`lastVerified` 값을 그대로 사용해, 모든
/// URL이 같은 날짜로 찍히지 않도록 한다(값이 없으면 생략).
void main(List<String> args) {
  const baseUrl = 'https://sotongware-ai-story.web.app';

  var outDir = 'web';
  for (final arg in args) {
    if (arg.startsWith('--out=')) {
      outDir = arg.substring('--out='.length);
    }
  }

  final dataDir = Directory('assets/data');
  if (!dataDir.existsSync()) {
    stderr.writeln('assets/data 디렉터리를 찾을 수 없습니다. 프로젝트 루트에서 실행해주세요.');
    exit(1);
  }

  List<Map<String, dynamic>> readList(String file) {
    final f = File('${dataDir.path}/$file');
    if (!f.existsSync()) return [];
    final decoded = json.decode(f.readAsStringSync());
    if (decoded is! List) return [];
    return decoded.cast<Map<String, dynamic>>();
  }

  String siteLastUpdated = '';
  final siteUpdatesFile = File('${dataDir.path}/site_updates.json');
  if (siteUpdatesFile.existsSync()) {
    final decoded =
        json.decode(siteUpdatesFile.readAsStringSync()) as Map<String, dynamic>;
    siteLastUpdated = (decoded['siteLastUpdated'] ?? '').toString();
  }

  final timeline = readList('timeline.json');
  final eras = readList('eras.json');
  final concepts = readList('concepts.json');
  final tools = readList('ai_tools.json');
  final useCases = readList('use_cases.json');
  final workflows = readList('workflows.json');
  final glossary = readList('glossary.json');
  final future = readList('future_trends.json');

  /// 콘텐츠 목록에서 가장 최근의 `verifiedAt`/`lastVerified` 값을 찾는다.
  /// 상위 목록 페이지의 `lastmod`로 사용해 "모든 URL이 같은 날짜"가 되는
  /// 것을 피한다.
  String latestDate(List<Map<String, dynamic>> items, String field) {
    var latest = '';
    for (final item in items) {
      final value = (item[field] ?? '').toString();
      if (value.isNotEmpty && value.compareTo(latest) > 0) latest = value;
    }
    return latest;
  }

  final entries = <_SitemapEntry>[];
  final seenPaths = <String>{};

  void addEntry(String path, {String lastmod = '', double priority = 0.6}) {
    if (!seenPaths.add(path)) return; // 중복 제거
    entries.add(_SitemapEntry(path: path, lastmod: lastmod, priority: priority));
  }

  // --- 최상위 메뉴 경로 (검색/즐겨찾기 등 개인화 경로는 제외) ---
  addEntry('/', lastmod: siteLastUpdated, priority: 1.0);
  addEntry('/timeline', lastmod: latestDate(timeline, 'verifiedAt'), priority: 0.8);
  addEntry('/eras', lastmod: latestDate(eras, 'verifiedAt'), priority: 0.7);
  addEntry('/concepts', lastmod: latestDate(concepts, 'verifiedAt'), priority: 0.7);
  addEntry('/tools', lastmod: latestDate(tools, 'lastVerified'), priority: 0.9);
  addEntry('/tool-compare', priority: 0.5);
  addEntry('/use-cases', lastmod: latestDate(useCases, 'verifiedAt'), priority: 0.7);
  addEntry('/popular-ai', lastmod: latestDate(tools, 'lastVerified'), priority: 0.7);
  addEntry('/hidden-gems', lastmod: latestDate(tools, 'lastVerified'), priority: 0.6);
  addEntry('/workflows', lastmod: latestDate(workflows, 'verifiedAt'), priority: 0.7);
  addEntry('/korea-ai', priority: 0.6);
  addEntry('/industry-ai', priority: 0.6);
  addEntry('/developer', priority: 0.6);
  addEntry('/safety', priority: 0.6);
  addEntry('/future', lastmod: latestDate(future, 'verifiedAt'), priority: 0.6);
  addEntry('/glossary', lastmod: latestDate(glossary, 'verifiedAt'), priority: 0.6);
  addEntry('/sources', lastmod: siteLastUpdated, priority: 0.5);
  addEntry('/about', priority: 0.4);

  // --- 상세 페이지 ---
  for (final t in timeline) {
    addEntry(
      '/timeline/${t['id']}',
      lastmod: (t['verifiedAt'] ?? '').toString(),
      priority: 0.6,
    );
  }
  for (final e in eras) {
    addEntry(
      '/eras/${e['id']}',
      lastmod: (e['verifiedAt'] ?? '').toString(),
      priority: 0.5,
    );
  }
  for (final c in concepts) {
    addEntry(
      '/concepts/${c['id']}',
      lastmod: (c['verifiedAt'] ?? '').toString(),
      priority: 0.6,
    );
  }
  for (final t in tools) {
    addEntry(
      '/tools/${t['id']}',
      lastmod: (t['lastVerified'] ?? '').toString(),
      priority: 0.7,
    );
  }
  for (final u in useCases) {
    addEntry(
      '/use-cases/${u['id']}',
      lastmod: (u['verifiedAt'] ?? '').toString(),
      priority: 0.5,
    );
  }
  for (final w in workflows) {
    addEntry(
      '/workflows/${w['id']}',
      lastmod: (w['verifiedAt'] ?? '').toString(),
      priority: 0.6,
    );
  }
  for (final g in glossary) {
    addEntry(
      '/glossary/${g['id']}',
      lastmod: (g['verifiedAt'] ?? '').toString(),
      priority: 0.4,
    );
  }
  for (final f in future) {
    addEntry(
      '/future/${f['id']}',
      lastmod: (f['verifiedAt'] ?? '').toString(),
      priority: 0.4,
    );
  }

  final buffer = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">');
  for (final entry in entries) {
    buffer.writeln('  <url>');
    buffer.writeln('    <loc>$baseUrl${entry.path}</loc>');
    if (entry.lastmod.isNotEmpty) {
      buffer.writeln('    <lastmod>${entry.lastmod}</lastmod>');
    }
    buffer.writeln(
      '    <priority>${entry.priority.toStringAsFixed(1)}</priority>',
    );
    buffer.writeln('  </url>');
  }
  buffer.writeln('</urlset>');

  final outputDir = Directory(outDir);
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }
  final outputFile = File('${outputDir.path}/sitemap.xml');
  outputFile.writeAsStringSync(buffer.toString());

  print('sitemap.xml 생성 완료: ${outputFile.path}');
  print('총 URL 수: ${entries.length}개');
}

class _SitemapEntry {
  _SitemapEntry({
    required this.path,
    required this.lastmod,
    required this.priority,
  });

  final String path;
  final String lastmod;
  final double priority;
}
