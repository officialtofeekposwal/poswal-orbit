# Poswal Orbit Website

Static, zero-dependency official product website for Poswal Orbit, designed for GitHub Pages deployment.

## Architecture & Build System

- **Build Script:** `build.mjs` (pure Node.js ESM, zero runtime npm dependencies).
- **Template & CSS:** `src/template.html`, `src/css/style.css`, and language-specific font stylesheets (`src/css/font-hi.css`, `src/css/font-ur.css`).
- **Languages:** English (`/`), Hindi (`/hi/`), and Urdu RTL (`/ur/`).
- **Budgets:** HTML + CSS + JS transfer under 120 KB per page (excluding self-hosted fonts).
- **Security & Privacy:** Strict Content Security Policy (`default-src 'self'`), zero runtime network calls, zero cookies, zero analytics.

## Font Loading Strategy

To ensure zero unnecessary font requests across routes:
- Latin fonts (`Plus Jakarta Sans` and `Inter`) are declared in `style.css` and loaded on all pages.
- `Noto Sans Devanagari` is declared only in `font-hi.css` and conditionally linked exclusively on `/hi/`.
- `Noto Nastaliq Urdu` is declared only in `font-ur.css` and conditionally linked exclusively on `/ur/`.
- The root route `/` loads zero Devanagari and zero Nastaliq webfonts.

## GitHub Pages Deployment & Subpath Notice

When deployed to GitHub Pages under a project path (e.g. `https://officialtofeekposwal.github.io/poswal-orbit/`), web crawlers request `robots.txt` from the domain root (`https://officialtofeekposwal.github.io/robots.txt`) rather than from the repository subpath (`/poswal-orbit/robots.txt`), which is a known GitHub Pages platform limitation for project-level sites.

## Preview Server

```bash
# Preview locally (127.0.0.1:8080)
node website/serve.mjs

# Preview over local Wi-Fi on a phone (0.0.0.0:8080)
node website/serve.mjs --host 0.0.0.0
```
