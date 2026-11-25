# DECLON AGENCY

The root site is a responsive, static landing page for DECLON AGENCY. It introduces the agency, its strategic and creative services, and its approach to international market expansion.

## Run locally

Open `index.html` in a browser or run the included PowerShell static server:

```powershell
powershell -ExecutionPolicy Bypass -File .\server.ps1
```

The page uses `agency.css` and `agency.js`; it has no build step or package dependencies. The hero photograph and web fonts are loaded from external providers.

## Publishing

The configured GitHub Pages site serves the repository root from `main`. Publishing this landing page requires merging the changes to `main`; the public URL is `https://anwarjr369.github.io/delcon/`.

The previous JEE PYQ platform files and image assets remain in the repository, but are no longer referenced by the root page.
