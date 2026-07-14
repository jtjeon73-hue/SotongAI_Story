// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// 출처 URL HTTP 상태를 점검한다.
///
/// 실행: `dart run tool/check_source_links.dart`
///
/// 네트워크 실패를 콘텐츠 오류로 단정하지 않는다. 결과는 분류만 출력한다.
Future<void> main() async {
  final file = File('assets/data/sources.json');
  if (!file.existsSync()) {
    stderr.writeln('assets/data/sources.json 없음');
    exit(1);
  }
  final sources = (json.decode(file.readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();

  var ok = 0;
  var redirect = 0;
  var notFound = 0;
  var denied = 0;
  var timeout = 0;
  var manual = 0;

  final client = http.Client();
  try {
    for (final source in sources) {
      final id = source['id']?.toString() ?? '';
      final url = source['url']?.toString() ?? '';
      if (url.isEmpty) {
        manual++;
        print('MANUAL_EMPTY\t$id');
        continue;
      }
      try {
        final uri = Uri.parse(url);
        final response = await client
            .head(uri)
            .timeout(const Duration(seconds: 12));
        final code = response.statusCode;
        if (code >= 200 && code < 300) {
          ok++;
          print('OK\t$code\t$id');
        } else if (code >= 300 && code < 400) {
          redirect++;
          print('REDIRECT\t$code\t$id\t$url');
        } else if (code == 404) {
          notFound++;
          print('NOT_FOUND\t$code\t$id');
        } else if (code == 401 || code == 403) {
          denied++;
          print('DENIED\t$code\t$id');
        } else {
          manual++;
          print('MANUAL\t$code\t$id');
        }
      } on SocketException catch (e) {
        timeout++;
        print('NETWORK\t$id\t$e');
      } catch (e) {
        // HEAD 거부 시 GET을 한 번 더 시도
        try {
          final response = await client
              .get(Uri.parse(url))
              .timeout(const Duration(seconds: 12));
          final code = response.statusCode;
          if (code >= 200 && code < 300) {
            ok++;
            print('OK_GET\t$code\t$id');
          } else if (code >= 300 && code < 400) {
            redirect++;
            print('REDIRECT_GET\t$code\t$id');
          } else {
            manual++;
            print('MANUAL_GET\t$code\t$id');
          }
        } catch (_) {
          timeout++;
          print('TIMEOUT_OR_ERROR\t$id\t$e');
        }
      }
    }
  } finally {
    client.close();
  }

  print('---');
  print('total=${sources.length}');
  print('ok=$ok redirect=$redirect notFound=$notFound denied=$denied timeout=$timeout manual=$manual');
}
