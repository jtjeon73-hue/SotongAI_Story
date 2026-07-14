# 흰 화면 진단 기록 (blank_fix)

기록 시각: 2026-07-14  
대상: https://sotongware-ai-story.web.app/?blank_fix=1

## 관측된 HTTP/헤더 (자동 확인)

- HTTP Status: **200**
- `Content-Security-Policy` (응답 헤더에 존재):

```
default-src 'self';
script-src 'self' 'unsafe-inline' 'unsafe-eval' 'wasm-unsafe-eval';
style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
font-src 'self' https://fonts.gstatic.com data:;
img-src 'self' data: blob: https:;
connect-src 'self' https://fonts.googleapis.com https://fonts.gstatic.com;
worker-src 'self' blob:;
base-uri 'self';
frame-ancestors 'self';
object-src 'none'
```

- `X-Content-Type-Options: nosniff` 존재
- HTML에 `flutter_bootstrap.js`, `<base href="/">` 존재
- `main.dart.js`, `flutter_bootstrap.js`, `AssetManifest.bin.json` HTTP 200 · 파일 크기 정상(0 바이트 아님)

## Flutter 빌드 설정 (로컬 build/web)

`flutter_bootstrap.js` buildConfig:

```
"renderer":"canvaskit"
"engineRevision":"a10d8ac38de835021c8d2f920dbf50a920ccc030"
```

CanvasKit 렌더러는 일반적으로 `https://www.gstatic.com/flutter-canvaskit/...` 리소스에
스크립트/wasm/`connect` 접근이 필요하다.

## 원인으로 추정되는 설정 (근거 기반)

1. **최유력: CSP `connect-src`가 `www.gstatic.com`을 허용하지 않음**  
   → CanvasKit fetch/wasm 로딩이 CSP에 의해 차단될 수 있음  
   → title/favicon만 보이고 Flutter UI 미렌더링 증상과 일치

2. SEO `generate_seo_pages`는 root `index.html`에 bootstrap script를 유지함  
   (현재 HTML 검사: `flutter_bootstrap.js` 존재) → SEO 단독 원인 가능성 낮음

3. Service Worker 캐시는 2차 요인일 수 있으나, **신규 시크릿에서도 CSP 헤더가 적용**되므로
   CSP를 먼저 제거하는 것이 타당

## Chrome Console 오류 원문 (Playwright 확인)

```
Connecting to 'https://www.gstatic.com/flutter-canvaskit/.../chromium/canvaskit.wasm'
violates the following Content Security Policy directive:
"connect-src 'self' https://fonts.googleapis.com https://fonts.gstatic.com".
The action has been blocked.

Fetch API cannot load https://www.gstatic.com/flutter-canvaskit/.../canvaskit.wasm.
Refused to connect because it violates the document's Content Security Policy.

Loading the script 'https://www.gstatic.com/flutter-canvaskit/.../chromium/canvaskit.js'
violates the following Content Security Policy directive:
"script-src 'self' 'unsafe-inline' 'unsafe-eval' 'wasm-unsafe-eval'".
The action has been blocked.

pageerror: TypeError: Failed to fetch dynamically imported module:
https://www.gstatic.com/flutter-canvaskit/.../chromium/canvaskit.js
```

## 실패 Network 요청

- `https://www.gstatic.com/flutter-canvaskit/a10d8ac38de835021c8d2f920dbf50a920ccc030/chromium/canvaskit.js` → **CSP blocked**
- 동반 `canvaskit.wasm` → **CSP connect-src blocked**

## 렌더링 상태 (수정 전)

- `flt-glass-pane`: false
- `flutter-view`: false
- canvas: 0
- body text length: 0
- title만 존재

## 결론

**원인 확정: firebase.json Content-Security-Policy가 Flutter CanvasKit(gstatic) 로딩을 차단.**

SEO 생성 도구/SW는 이번 증상의 직접 원인이 아님(bootstrap 정상, CSP 위반 메시지 명확).
