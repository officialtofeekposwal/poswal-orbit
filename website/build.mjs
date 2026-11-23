/**
 * Poswal Orbit · Static Site Generator
 * Zero runtime external dependencies. Node.js only.
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Base configuration
const BASE_PATH = process.env.BASE_PATH || '/poswal-orbit/';
const SITE_URL = 'https://officialtofeekposwal.github.io/poswal-orbit/';

const ROOT_DIR = path.resolve(__dirname, '..');
const WEBSITE_DIR = __dirname;
const SRC_DIR = path.join(WEBSITE_DIR, 'src');
const ASSETS_DIR = path.join(WEBSITE_DIR, 'assets');
const STATIC_DIR = path.join(WEBSITE_DIR, 'static');
const DATA_DIR = path.join(WEBSITE_DIR, 'data');
const I18N_DIR = path.join(WEBSITE_DIR, 'i18n');
const DIST_DIR = path.join(WEBSITE_DIR, 'dist');

console.log('[1/6] Auditing i18n JSON files for parity and strict rules...');

const languages = ['en', 'hi', 'ur'];
const i18nData = {};

for (const lang of languages) {
  const filePath = path.join(I18N_DIR, `${lang}.json`);
  if (!fs.existsSync(filePath)) {
    console.error(`FATAL: Missing i18n file: ${filePath}`);
    process.exit(1);
  }
  i18nData[lang] = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
}

// 1. Strict i18n Validation
function getAllKeys(obj, prefix = '') {
  let keys = [];
  for (const [k, v] of Object.entries(obj)) {
    const fullKey = prefix ? `${prefix}.${k}` : k;
    if (v && typeof v === 'object' && !Array.isArray(v)) {
      keys = keys.concat(getAllKeys(v, fullKey));
    } else {
      keys.push({ key: fullKey, value: String(v) });
    }
  }
  return keys;
}

const enEntries = getAllKeys(i18nData.en);
const enKeySet = new Set(enEntries.map(e => e.key));

for (const lang of ['hi', 'ur']) {
  const langEntries = getAllKeys(i18nData[lang]);
  const langKeySet = new Set(langEntries.map(e => e.key));

  for (const k of enKeySet) {
    if (!langKeySet.has(k)) {
      console.error(`FATAL: Missing key "${k}" in ${lang}.json`);
      process.exit(1);
    }
  }
  for (const k of langKeySet) {
    if (!enKeySet.has(k)) {
      console.error(`FATAL: Extra key "${k}" in ${lang}.json that does not exist in en.json`);
      process.exit(1);
    }
  }
}

// Strict content validator: no emojis, no exclamation marks, no placeholders, no emails, no phone numbers
const emojiRegex = /\p{Extended_Pictographic}/u;
const placeholderRegex = /YOUR_|example\.com|TODO|lorem/i;
const emailRegex = /[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+/;
const phoneRegex = /(?:\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}|\b\d{10}\b|\b\d{3}[-.\s]\d{3}[-.\s]\d{4}\b/;

for (const lang of languages) {
  const entries = getAllKeys(i18nData[lang]);
  for (const { key, value } of entries) {
    if (emojiRegex.test(value)) {
      console.error(`FATAL: Forbidden emoji found in ${lang}.json at key "${key}": "${value}"`);
      process.exit(1);
    }
    if (value.includes('!') || value.includes('！')) {
      console.error(`FATAL: Forbidden exclamation mark found in ${lang}.json at key "${key}": "${value}"`);
      process.exit(1);
    }
    if (placeholderRegex.test(value)) {
      console.error(`FATAL: Forbidden placeholder found in ${lang}.json at key "${key}": "${value}"`);
      process.exit(1);
    }
    if (emailRegex.test(value)) {
      console.error(`FATAL: Forbidden email address found in ${lang}.json at key "${key}": "${value}"`);
      process.exit(1);
    }
    if (phoneRegex.test(value)) {
      console.error(`FATAL: Forbidden phone number pattern found in ${lang}.json at key "${key}": "${value}"`);
      process.exit(1);
    }
  }
}
console.log('✓ i18n parity, zero-emoji, zero-exclamation, zero-email, zero-phone validation passed.');

// 2. Derive Pubspec & Test Counts dynamically
console.log('[2/6] Deriving architecture specs from pubspec.yaml and test suite...');

const pubspecPath = path.join(ROOT_DIR, 'pubspec.yaml');
let dartSdk = '^3.14.0';
let riverpodVer = '^3.5.0';
let driftVer = '^2.35.4';

if (fs.existsSync(pubspecPath)) {
  const pubContent = fs.readFileSync(pubspecPath, 'utf-8');
  const sdkMatch = pubContent.match(/sdk:\s*([^\r\n]+)/);
  if (sdkMatch) dartSdk = sdkMatch[1].trim();

  const rivMatch = pubContent.match(/flutter_riverpod:\s*([^\r\n]+)/);
  if (rivMatch) riverpodVer = rivMatch[1].trim();

  const driftMatch = pubContent.match(/drift:\s*([^\r\n]+)/);
  if (driftMatch) driftVer = driftMatch[1].trim();
}

// Recursively count test( and testWidgets( declarations
function countTestsInDir(dir) {
  let count = 0;
  let fileCount = 0;
  if (!fs.existsSync(dir)) return { count: 0, fileCount: 0 };

  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      const sub = countTestsInDir(fullPath);
      count += sub.count;
      fileCount += sub.fileCount;
    } else if (entry.isFile() && entry.name.endsWith('.dart')) {
      fileCount++;
      const content = fs.readFileSync(fullPath, 'utf-8');
      const matches = content.match(/^\s*(test|testWidgets)\s*\(/gm);
      if (matches) count += matches.length;
    }
  }
  return { count, fileCount };
}

const testStats = countTestsInDir(path.join(ROOT_DIR, 'test'));
console.log(`✓ Derived specs: Dart SDK ${dartSdk}, Riverpod ${riverpodVer}, Drift ${driftVer}, Tests: ${testStats.count} across ${testStats.fileCount} files.`);

// 3. Read Release Metadata
console.log('[3/6] Reading release metadata from website/data/release.json...');

const releaseFile = path.join(DATA_DIR, 'release.json');
let releaseInfo = {
  hasRelease: false,
  tagName: 'Pre-release',
  apkUrl: 'https://github.com/officialtofeekposwal/poswal-orbit/releases',
  apkSize: '',
  apkSha256: ''
};

if (fs.existsSync(releaseFile)) {
  try {
    const parsed = JSON.parse(fs.readFileSync(releaseFile, 'utf-8'));
    releaseInfo = { ...releaseInfo, ...parsed };
    console.log(`✓ Release detected: ${releaseInfo.tagName} (hasRelease: ${releaseInfo.hasRelease})`);
  } catch (err) {
    console.warn('Warning: Could not parse release.json, using fallback.');
  }
} else {
  console.log('Notice: No release.json found. Sideload fallback will be shown.');
}

// 4. Clean and prepare dist directory
console.log('[4/6] Setting up output directories in website/dist/...');
if (fs.existsSync(DIST_DIR)) {
  fs.rmSync(DIST_DIR, { recursive: true, force: true });
}
fs.mkdirSync(DIST_DIR, { recursive: true });
fs.mkdirSync(path.join(DIST_DIR, 'hi'), { recursive: true });
fs.mkdirSync(path.join(DIST_DIR, 'ur'), { recursive: true });
fs.mkdirSync(path.join(DIST_DIR, 'assets', 'css'), { recursive: true });
fs.mkdirSync(path.join(DIST_DIR, 'assets', 'js'), { recursive: true });

// Copy Assets recursively
function copyDir(src, dest) {
  if (!fs.existsSync(src)) return;
  fs.mkdirSync(dest, { recursive: true });
  for (const item of fs.readdirSync(src, { withFileTypes: true })) {
    const s = path.join(src, item.name);
    const d = path.join(dest, item.name);
    if (item.isDirectory()) {
      copyDir(s, d);
    } else {
      fs.copyFileSync(s, d);
    }
  }
}

copyDir(ASSETS_DIR, path.join(DIST_DIR, 'assets'));

// Copy CSS and JS
fs.copyFileSync(path.join(SRC_DIR, 'css', 'style.css'), path.join(DIST_DIR, 'assets', 'css', 'style.css'));
fs.copyFileSync(path.join(SRC_DIR, 'js', 'main.js'), path.join(DIST_DIR, 'assets', 'js', 'main.js'));

// Copy Static files
for (const file of fs.readdirSync(STATIC_DIR)) {
  fs.copyFileSync(path.join(STATIC_DIR, file), path.join(DIST_DIR, file));
}

// 5. Render Templates
console.log('[5/6] Rendering static pages from template.html...');
const template = fs.readFileSync(path.join(SRC_DIR, 'template.html'), 'utf-8');

function renderTemplate(tpl, context) {
  let output = tpl;

  // Handle simple conditionals: {{#if key}}...{{else}}...{{/if}} or {{#if key}}...{{/if}}
  output = output.replace(/\{\{#if\s+([\w.]+)\}\}([\s\S]*?)(?:\{\{else\}\}([\s\S]*?))?\{\{\/if\}\}/g, (match, cond, trueBranch, falseBranch = '') => {
    const val = getNestedValue(context, cond);
    return val ? trueBranch : falseBranch;
  });

  // Replace variable tokens: {{variable.path}}
  output = output.replace(/\{\{([\w.]+)\}\}/g, (match, key) => {
    const val = getNestedValue(context, key);
    return val !== undefined ? String(val) : '';
  });

  return output;
}

function getNestedValue(obj, pathStr) {
  return pathStr.split('.').reduce((acc, part) => (acc && acc[part] !== undefined ? acc[part] : undefined), obj);
}

const pageConfigs = [
  {
    lang: 'en',
    dir: 'ltr',
    isEn: true,
    isHi: false,
    isUr: false,
    ogLocale: 'en_US',
    canonicalUrl: SITE_URL,
    pagePath: './',
    assetPath: '',
    outputPath: path.join(DIST_DIR, 'index.html')
  },
  {
    lang: 'hi',
    dir: 'ltr',
    isEn: false,
    isHi: true,
    isUr: false,
    ogLocale: 'hi_IN',
    canonicalUrl: `${SITE_URL}hi/`,
    pagePath: './',
    assetPath: '../',
    outputPath: path.join(DIST_DIR, 'hi', 'index.html')
  },
  {
    lang: 'ur',
    dir: 'rtl',
    isEn: false,
    isHi: false,
    isUr: true,
    ogLocale: 'ur_PK',
    canonicalUrl: `${SITE_URL}ur/`,
    pagePath: './',
    assetPath: '../',
    outputPath: path.join(DIST_DIR, 'ur', 'index.html')
  }
];

const derivedSpecs = {
  dartSdk,
  riverpod: riverpodVer,
  drift: driftVer,
  testCount: testStats.count,
  testFiles: testStats.fileCount
};

for (const cfg of pageConfigs) {
  const context = {
    ...i18nData[cfg.lang],
    lang: cfg.lang,
    dir: cfg.dir,
    isEn: cfg.isEn,
    isHi: cfg.isHi,
    isUr: cfg.isUr,
    ogLocale: cfg.ogLocale,
    baseUrl: BASE_PATH,
    canonicalUrl: cfg.canonicalUrl,
    pagePath: cfg.pagePath,
    assetPath: cfg.assetPath,
    hasRelease: Boolean(releaseInfo.hasRelease),
    releaseTag: releaseInfo.tagName || 'Pre-release',
    apkUrl: releaseInfo.apkUrl || '#install',
    apkSize: releaseInfo.apkSize || '',
    apkSha256: releaseInfo.apkSha256 || '',
    derivedSpecs
  };

  const html = renderTemplate(template, context);
  fs.writeFileSync(cfg.outputPath, html, 'utf-8');
  console.log(`✓ Generated ${cfg.outputPath}`);
}

// Generate sitemap.xml
const sitemapContent = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">
  <url>
    <loc>${SITE_URL}</loc>
    <xhtml:link rel="alternate" hreflang="en" href="${SITE_URL}"/>
    <xhtml:link rel="alternate" hreflang="hi" href="${SITE_URL}hi/"/>
    <xhtml:link rel="alternate" hreflang="ur" href="${SITE_URL}ur/"/>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>${SITE_URL}hi/</loc>
    <xhtml:link rel="alternate" hreflang="en" href="${SITE_URL}"/>
    <xhtml:link rel="alternate" hreflang="hi" href="${SITE_URL}hi/"/>
    <xhtml:link rel="alternate" hreflang="ur" href="${SITE_URL}ur/"/>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>
  <url>
    <loc>${SITE_URL}ur/</loc>
    <xhtml:link rel="alternate" hreflang="en" href="${SITE_URL}"/>
    <xhtml:link rel="alternate" hreflang="hi" href="${SITE_URL}hi/"/>
    <xhtml:link rel="alternate" hreflang="ur" href="${SITE_URL}ur/"/>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>
</urlset>
`;
fs.writeFileSync(path.join(DIST_DIR, 'sitemap.xml'), sitemapContent.trim(), 'utf-8');
console.log('✓ Generated sitemap.xml');

// 6. Transfer Budget & Asset Size Verification
console.log('[6/6] Verifying per-page transfer budgets (< 120 KB HTML+CSS+JS excluding fonts)...');

const cssSize = fs.statSync(path.join(DIST_DIR, 'assets', 'css', 'style.css')).size;
const jsSize = fs.statSync(path.join(DIST_DIR, 'assets', 'js', 'main.js')).size;

for (const cfg of pageConfigs) {
  const htmlSize = fs.statSync(cfg.outputPath).size;
  const coreTotal = htmlSize + cssSize + jsSize;
  const coreTotalKB = (coreTotal / 1024).toFixed(2);

  console.log(`Route [/${cfg.lang === 'en' ? '' : cfg.lang + '/'}]: HTML=${(htmlSize / 1024).toFixed(2)} KB, CSS=${(cssSize / 1024).toFixed(2)} KB, JS=${(jsSize / 1024).toFixed(2)} KB. Total=${coreTotalKB} KB.`);

  if (coreTotal > 120 * 1024) {
    console.error(`FATAL: Budget exceeded on route ${cfg.lang}! Total is ${coreTotalKB} KB (limit: 120 KB)`);
    process.exit(1);
  }
}

// Print font sizes
console.log('\n--- Self-Hosted Font Breakdown ---');
const fontsDir = path.join(DIST_DIR, 'assets', 'fonts');
if (fs.existsSync(fontsDir)) {
  for (const f of fs.readdirSync(fontsDir)) {
    if (f.endsWith('.woff2')) {
      const sz = fs.statSync(path.join(fontsDir, f)).size;
      console.log(`- ${f}: ${(sz / 1024).toFixed(2)} KB`);
    }
  }
}

console.log('\n✅ Build completed successfully with 100% checks passing!\n');
