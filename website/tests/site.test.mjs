/**
 * Poswal Orbit · Website Test Suite
 * Native Node.js test runner (node --test)
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const DIST_DIR = path.resolve(__dirname, '..', 'dist');

test('Website Distribution: Core files exist', () => {
  const requiredFiles = [
    'index.html',
    'hi/index.html',
    'ur/index.html',
    '404.html',
    'robots.txt',
    'sitemap.xml',
    'site.webmanifest',
    'assets/css/style.css',
    'assets/js/main.js',
    'assets/fonts/OFL.txt',
    'assets/images/favicon.svg',
    'assets/images/og-image.png'
  ];

  for (const relPath of requiredFiles) {
    const fullPath = path.join(DIST_DIR, relPath);
    assert.ok(fs.existsSync(fullPath), `Expected file to exist: ${relPath}`);
  }
});

test('Website Metadata: Canonical, hreflangs, and CSP in all pages', () => {
  const pages = [
    { file: 'index.html', lang: 'en', dir: 'ltr', canonical: 'https://officialtofeekposwal.github.io/poswal-orbit/' },
    { file: 'hi/index.html', lang: 'hi', dir: 'ltr', canonical: 'https://officialtofeekposwal.github.io/poswal-orbit/hi/' },
    { file: 'ur/index.html', lang: 'ur', dir: 'rtl', canonical: 'https://officialtofeekposwal.github.io/poswal-orbit/ur/' }
  ];

  for (const p of pages) {
    const html = fs.readFileSync(path.join(DIST_DIR, p.file), 'utf-8');

    // Lang and dir
    assert.ok(html.includes(`lang="${p.lang}"`), `${p.file} must have lang="${p.lang}"`);
    assert.ok(html.includes(`dir="${p.dir}"`), `${p.file} must have dir="${p.dir}"`);

    // Canonical
    assert.ok(html.includes(`rel="canonical" href="${p.canonical}"`), `${p.file} must have correct canonical URL`);

    // Reciprocal hreflangs
    assert.ok(html.includes('hreflang="en"'), `${p.file} must have hreflang="en"`);
    assert.ok(html.includes('hreflang="hi"'), `${p.file} must have hreflang="hi"`);
    assert.ok(html.includes('hreflang="ur"'), `${p.file} must have hreflang="ur"`);
    assert.ok(html.includes('hreflang="x-default"'), `${p.file} must have hreflang="x-default"`);

    // Strict CSP
    assert.ok(html.includes('Content-Security-Policy'), `${p.file} must declare Content-Security-Policy`);
    assert.ok(html.includes("default-src 'self'"), `${p.file} must have default-src 'self'`);

    // Accessibility skip link
    assert.ok(html.includes('class="skip-link"'), `${p.file} must have skip link for accessibility`);
  }
});

test('Website Privacy & Security: Zero external network calls', () => {
  const htmlFiles = ['index.html', 'hi/index.html', 'ur/index.html', '404.html'];
  const css = fs.readFileSync(path.join(DIST_DIR, 'assets', 'css', 'style.css'), 'utf-8');
  const js = fs.readFileSync(path.join(DIST_DIR, 'assets', 'js', 'main.js'), 'utf-8');

  // Check CSS imports
  assert.ok(!css.includes('@import url('), 'CSS must not import external stylesheets');
  assert.ok(!css.includes('http://') && !css.includes('https://'), 'CSS must not reference remote URLs');

  // Check JS external calls
  assert.ok(!js.includes('fetch(') && !js.includes('XMLHttpRequest'), 'Client JS must not make runtime network calls');

  // Check HTML scripts and styles
  for (const f of htmlFiles) {
    const html = fs.readFileSync(path.join(DIST_DIR, f), 'utf-8');
    const externalScriptMatch = html.match(/<script[^>]+src=["'](https?:|\/\/)[^"']+["']/i);
    assert.equal(externalScriptMatch, null, `${f} must not contain external scripts`);

    const externalStyleMatch = html.match(/<link[^>]+rel=["']stylesheet["'][^>]+href=["'](https?:|\/\/)[^"']+["']/i);
    assert.equal(externalStyleMatch, null, `${f} must not contain external stylesheets`);
  }
});

test('Website Quality: Zero emojis, zero exclamation marks, zero emails, zero phone numbers, zero placeholders in copy', () => {
  const htmlFiles = ['index.html', 'hi/index.html', 'ur/index.html'];
  const emojiRegex = /\p{Extended_Pictographic}/u;
  const placeholderRegex = /YOUR_|example\.com|TODO|lorem/i;
  const emailRegex = /[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+/;
  const phoneRegex = /(?:\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}|\b\d{10}\b|\b\d{3}[-.\s]\d{3}[-.\s]\d{4}\b/;

  for (const f of htmlFiles) {
    const html = fs.readFileSync(path.join(DIST_DIR, f), 'utf-8');

    // No emojis
    assert.ok(!emojiRegex.test(html), `${f} must not contain any emoji`);

    // No email address
    assert.ok(!emailRegex.test(html), `${f} must not contain any email address`);

    // No phone numbers
    assert.ok(!phoneRegex.test(html), `${f} must not contain phone number patterns`);

    // No placeholders
    assert.ok(!placeholderRegex.test(html), `${f} must not contain placeholder strings`);

    // Strip DOCTYPE, HTML comments (which might contain <!-- ... -->), and check visible copy for exclamation marks
    const cleanHtml = html.replace(/<!DOCTYPE[^>]*>/gi, '').replace(/<!--[\s\S]*?-->/g, '');
    // In copy, neither Latin ! nor fullwidth ！ is allowed
    assert.ok(!cleanHtml.includes('!') && !cleanHtml.includes('！'), `${f} copy must not contain exclamation marks`);
  }
});

test('Website Performance Budgets: Per-page HTML+CSS+JS under 120 KB (excluding fonts)', () => {
  const cssSize = fs.statSync(path.join(DIST_DIR, 'assets', 'css', 'style.css')).size;
  const jsSize = fs.statSync(path.join(DIST_DIR, 'assets', 'js', 'main.js')).size;

  assert.ok(jsSize < 25 * 1024, `JS payload must be under 25 KB (is ${(jsSize / 1024).toFixed(2)} KB)`);

  const pages = ['index.html', 'hi/index.html', 'ur/index.html'];
  for (const p of pages) {
    const htmlSize = fs.statSync(path.join(DIST_DIR, p)).size;
    const total = htmlSize + cssSize + jsSize;
    assert.ok(total < 120 * 1024, `${p} total transfer budget must be under 120 KB (is ${(total / 1024).toFixed(2)} KB)`);
  }
});
