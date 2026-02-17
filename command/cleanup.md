---
description: Perform a comprehensive project cleanup, optimization, and standardization pass.
---

# CLEANUP COMMAND

## OVERVIEW
Performs a comprehensive project cleanup, optimization, and standardization pass.

## STEPS

1.  **FILE & GIT HYGIENE**
    -   **Trash Removal**: Delete tmp, logs, .DS_Store, Thumbs.db.
    -   **Organization**: Move loose files to `src`, `docs`, `scripts`.
    -   **Gitignore**: Update to exclude artifacts, secrets, system files.
    -   **Branch Pruning**: Delete local branches already merged to main.
    -   **Large Files**: Warn if committing files >50MB.
    -   **Squash Check**: Detect "wip"/"fix" commit chains; suggest squashing.

2.  **ASSET OPTIMIZATION**
    -   **Images**: Compress PNG/JPGs (lossless preferred) or convert to WebP.
        -   *CRITICAL*: If converting formats, grep codebase and update ALL references (e.g., `img.png` -> `img.webp`).
    -   **SVGs**: Run optimization to strip metadata.

3.  **CODE CLEANUP & HEALTH**
    -   **Ghost Code**: Aggressively delete blocks of commented-out code.
    -   **Console Logs**: Remove `console.log` from production files (keep warn/error).
    -   **Dead Code**: Remove unused exports/imports/variables.
    -   **TODOs**: Collect `// TODO`s into a report; delete empty ones.
    -   **Debug Menus**: Hide or protect debug UIs.

4.  **CONFIG & STRUCTURE**
    -   **Consolidation**: Move standalone config files (prettierrc, etc.) to `.config/` or `package.json` where supported.
    -   **Standard Scripts**: Ensure `package.json` has standard `start`, `build`, `test`, `lint`.
    -   **Dependencies**: Run audit; update minor/patch versions.
    -   **License**: Ensure valid LICENSE file exists.

5.  **QUALITY & PERFORMANCE**
    -   **Formatting**: Run project-wide formatter.
    -   **Type Check**: Report excessive `any` usage (if TypeScript).
    -   **Link Rot**: Check README/docs for broken URLs.
    -   **Bundle Budget**: If buildable, check if bundle >500KB and warn.

6.  **WEB SPECIFICS (If Website)**
    -   **SEO**: Invoke `seo` skill for content/meta tags.
    -   **Favicon**: Ensure favicon exists; generate from logo if missing.

7.  **DOCUMENTATION**
    -   **Style**: Enforce `/microck-writing` on README.md.
    -   **GitHub Metadata**: Extract 1-line description and generate 10 topic tags.

8.  **AUTOMATION**
    -   **Actions**: Add basic GitHub Actions (lint/build) if missing.

9.  **FINALIZATION**
    -   **Secrets Scan**: Check for keys/tokens.
    -   **Push**: Commit (`chore: project cleanup`) and push.

## OUTPUT
-   One-line description & 10 tags.
-   TODO report.
-   Summary of optimizations (space saved, files cleaned).
