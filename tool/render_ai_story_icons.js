// Renders branding PNG assets from SVG sources for Sotong AI Story.
// Usage:
//   cd tool
//   npm install
//   node render_ai_story_icons.js

const fs = require('fs');
const path = require('path');
const { Resvg } = require('@resvg/resvg-js');

const repoRoot = path.resolve(__dirname, '..');

// Locate a Korean-capable font so Hangul text (e.g. in the OG image) renders
// correctly instead of falling back to tofu boxes. Windows ships Malgun
// Gothic by default; other platforms fall back to system font loading.
function findKoreanFontFiles() {
  const candidates = [
    'C:/Windows/Fonts/malgun.ttf',
    'C:/Windows/Fonts/malgunbd.ttf',
    '/usr/share/fonts/truetype/nanum/NanumGothic.ttf',
    '/System/Library/Fonts/Supplemental/AppleGothic.ttf',
  ];
  return candidates.filter((p) => fs.existsSync(p));
}

const koreanFontFiles = findKoreanFontFiles();

const ICON_SVG = path.join(repoRoot, 'web', 'icons', 'sotong_ai_story_icon.svg');
const MASKABLE_SVG = path.join(repoRoot, 'web', 'icons', 'sotong_ai_story_icon_maskable.svg');
const OG_SVG = path.join(repoRoot, 'web', 'icons', 'sotong_ai_story_og.svg');

const renderJobs = [
  {
    label: 'favicon.png (48x48)',
    svgPath: ICON_SVG,
    outPath: path.join(repoRoot, 'web', 'favicon.png'),
    width: 48,
    height: 48,
  },
  {
    label: 'Icon-192.png (192x192)',
    svgPath: ICON_SVG,
    outPath: path.join(repoRoot, 'web', 'icons', 'Icon-192.png'),
    width: 192,
    height: 192,
  },
  {
    label: 'Icon-512.png (512x512)',
    svgPath: ICON_SVG,
    outPath: path.join(repoRoot, 'web', 'icons', 'Icon-512.png'),
    width: 512,
    height: 512,
  },
  {
    label: 'Icon-maskable-192.png (192x192)',
    svgPath: MASKABLE_SVG,
    outPath: path.join(repoRoot, 'web', 'icons', 'Icon-maskable-192.png'),
    width: 192,
    height: 192,
  },
  {
    label: 'Icon-maskable-512.png (512x512)',
    svgPath: MASKABLE_SVG,
    outPath: path.join(repoRoot, 'web', 'icons', 'Icon-maskable-512.png'),
    width: 512,
    height: 512,
  },
  {
    label: 'og-image.png (1200x630)',
    svgPath: OG_SVG,
    outPath: path.join(repoRoot, 'web', 'og-image.png'),
    width: 1200,
    height: 630,
  },
];

function renderOne(job) {
  const svg = fs.readFileSync(job.svgPath, 'utf-8');

  const resvg = new Resvg(svg, {
    fitTo: {
      mode: 'width',
      value: job.width,
    },
    font: {
      loadSystemFonts: koreanFontFiles.length === 0,
      fontFiles: koreanFontFiles,
      defaultFontFamily: 'Malgun Gothic',
      sansSerifFamily: 'Malgun Gothic',
    },
    background: 'rgba(0,0,0,0)',
  });

  const rendered = resvg.render();
  const pngBuffer = rendered.asPng();

  fs.mkdirSync(path.dirname(job.outPath), { recursive: true });
  fs.writeFileSync(job.outPath, pngBuffer);

  const stats = fs.statSync(job.outPath);
  console.log(`  ✓ ${job.label} -> ${path.relative(repoRoot, job.outPath)} (${stats.size} bytes)`);
}

console.log('Rendering Sotong AI Story branding assets...\n');

for (const job of renderJobs) {
  try {
    renderOne(job);
  } catch (err) {
    console.error(`  ✗ Failed to render ${job.label}: ${err.message}`);
    process.exitCode = 1;
  }
}

console.log('\nDone.');
