# GitHub Pages Deployment Plan & Decisions

This document details the file tree, GitHub Actions automation workflow, required repository settings, and configuration choices for deploying the official Poswal Orbit website.

---

## 1. Directory Structure (`website/`)

```text
website/
├── build.mjs                  # Zero-dependency Node.js static generator (renders template + i18n JSON)
├── package.json               # Lightweight build metadata (type: module)
├── template.html              # Single semantic base template (strict CSP, zero external runtime calls)
├── i18n/
│   ├── en.json                # English strings
│   ├── hi.json                # Hindi (हिन्दी) strings
│   └── ur.json                # Urdu (اردو) strings with RTL text
├── assets/
│   ├── fonts/                 # Subsetted WOFF2 fonts + OFL licenses (Plus Jakarta Sans, Inter, Noto)
│   ├── icons/                 # Minimal inline SVGs (Phosphor Icons MIT)
│   ├── images/
│   │   ├── og-image.png       # 1200x630 OpenGraph card generated from vector assets
│   │   └── favicon.svg        # Scalable brand glyph
│   └── screens/               # Placeholder illustration SVGs; ready for device PNGs
├── docs/                      # Planning deliverables (Audits, specs, wireframes)
│   ├── 01_CLAIM_AUDIT.md
│   ├── 02_SITEMAP_AND_SECTIONS.md
│   ├── 03_DESIGN_TOKENS_AND_PERFORMANCE.md
│   ├── 04_DEPLOYMENT_PLAN.md
│   └── wireframes/
│       ├── wireframe-1280px.svg
│       └── wireframe-360px.svg
└── static/
    ├── robots.txt             # Disallows crawlers from raw data; points to sitemap.xml
    ├── sitemap.xml            # Lists /, /hi/, /ur/ with hreflang alternates
    ├── site.webmanifest       # PWA manifest with theme color #070B14
    └── 404.html               # Custom calm 404 error page with link back to orbit
```

---

## 2. GitHub Pages Deployment Workflow (`.github/workflows/pages.yml`)

The deployment workflow will run on GitHub Actions using the latest official actions:
- `actions/checkout@v4`
- `actions/configure-pages@v5`
- `actions/upload-pages-artifact@v3`
- `actions/deploy-pages@v4`

### Trigger Conditions:
1. `push` to `main` when paths include `website/**`.
2. `workflow_dispatch` (manual trigger).

### Permissions Required:
```yaml
permissions:
  contents: read
  pages: write
  id-token: write
```

### Build-Time Data Fetching:
Before running `build.mjs`, the workflow queries the GitHub API using the repository's built-in `GITHUB_TOKEN` to list all releases (`GET /repos/{owner}/{repo}/releases`, which includes pre-releases; note that `/releases/latest` does NOT return pre-releases). It selects the first non-draft release and writes `website/data/release.json`:
- `hasRelease`: boolean (`true` if a release was found, `false` otherwise)
- `tagName`: string (e.g. `v0.9.0-beta.1`)
- `isPrerelease`: boolean
- `publishedAt`: string (ISO 8601)
- `apkName`: name of release APK asset
- `apkUrl`: direct download URL
- `apkSize`: human-readable size
- `apkSha256`: SHA-256 digest
- `sha256Url`: URL to standalone checksum file if attached

If no release exists, `website/data/release.json` records `{"hasRelease": false}`. In that case, the Get It section automatically renders the honest "how to download artifacts from GitHub Actions CI" instructions with links to the Actions tab and unknown-sources enablement guidance.

*Reasoning*: Browsers visiting the website make **0 external network requests**. All release metrics and fallback states are baked into static HTML at build time. Note: External links in the author's profile README must point to `/releases` rather than hardcoding asset URLs.

---

## 3. Required Manual GitHub Settings

To enable Pages deployment once the workflow is committed in Stage 2:
1. Open your repository on GitHub: `https://github.com/officialtofeekposwal/poswal-orbit`.
2. Go to **Settings** $\to$ **Pages** (in the left sidebar).
3. Under **Build and deployment** $\to$ **Source**:
   - Change from *Deploy from a branch* to **GitHub Actions**.
4. Expected Live URL:
   ```text
   https://officialtofeekposwal.github.io/poswal-orbit/
   ```

---

## 4. Custom Domain Setup (Optional Future Step)

If you later purchase a custom domain (e.g., `poswalorbit.com` or `orbit.poswal.dev`):
1. In repository **Settings** $\to$ **Pages** $\to$ **Custom domain**: enter your domain.
2. Check **Enforce HTTPS**.
3. In your DNS provider (e.g., Cloudflare, Namecheap, GoDaddy):
   - For apex domain (`poswalorbit.com`): Add `A` records pointing to GitHub's IPs:
     `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`.
   - For subdomain (`orbit.poswal.com`): Add a `CNAME` record pointing to `officialtofeekposwal.github.io`.
4. The build script accepts a configurable `BASE` parameter, so switching from `/poswal-orbit/` to `/` is a single-variable change in `build.mjs`.

---

## 5. Decision & Open Questions Matrix

| # | Question / Topic | Recommendation | Reasoning |
|---|---|---|---|
| 1 | **Custom Domain** vs **github.io** | Use `github.io` initially (`officialtofeekposwal.github.io/poswal-orbit/`) | Completely free, zero maintenance, automatically managed SSL certificates. Seamless migration to a custom domain whenever you want. |
| 2 | **Contact Method** | GitHub Issues and GitHub Discussions only (no email) | Keeps public bug reporting structured, transparent, and spam-free without exposing private email addresses. |
| 3 | **Profile README Sync Note** | Direct links in profile README should point to `/releases` | Ensures users landing from your GitHub profile README navigate directly to the verified releases feed. |
| 4 | **Donation / Sponsorship Links** | Omit for now; add GitHub Sponsors later if desired | Keeps the site calm, distraction-free, and focused 100% on product quality and privacy. |
| 5 | **Interactive Simulator Scope** | Pure vanilla JS event listeners without libraries | Keeps total JS payload $< 25\text{ KB}$ and guarantees 60fps responsiveness on mid-range mobile devices. |
| 6 | **Screen Illustrations** | HTML/SVG layered mockups with a drop-in replacement folder | We have no real hardware screenshots yet. Once you take screenshots on your phone, dropping them into `website/assets/screens/` updates the site instantly. |
