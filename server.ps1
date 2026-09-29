# Lightweight local development server for Delcon Portfolio
param (
    [int]$Port = 8080,
    [switch]$NoBrowser
)

$siteDir = $PSScriptRoot
if (-not $siteDir) { $siteDir = Get-Location }

$listener = New-Object System.Net.HttpListener
$prefix = "http://localhost:$Port/"

try {
    $listener.Prefixes.Add($prefix)
    $listener.Start()
    Write-Host ">>> Delcon Website Server is LIVE at $prefix"
    Write-Host ">>> Serving files from: $siteDir"
    Write-Host ">>> Press Ctrl+C to stop the server."

    if (-not $NoBrowser) {
        try { Start-Process $prefix } catch {}
    }

    while ($listener.IsListening) {
        try {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response

            $relPath = $request.Url.LocalPath.TrimStart('/')
            if ([string]::IsNullOrEmpty($relPath) -or $relPath -eq "/") {
                $relPath = "index.html"
            }

            # Prevent directory traversal
            $filePath = [System.IO.Path]::GetFullPath((Join-Path $siteDir $relPath))
            if (-not $filePath.StartsWith($siteDir, [System.StringComparison]::OrdinalIgnoreCase)) {
                $response.StatusCode = 403
                try { $response.OutputStream.Close() } catch {}
                continue
            }

            if (Test-Path $filePath -PathType Leaf) {
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                switch ($ext) {
                    ".html" { $response.ContentType = "text/html; charset=utf-8" }
                    ".css"  { $response.ContentType = "text/css; charset=utf-8" }
                    ".js"   { $response.ContentType = "application/javascript; charset=utf-8" }
                    ".json" { $response.ContentType = "application/json; charset=utf-8" }
                    ".svg"  { $response.ContentType = "image/svg+xml" }
                    ".png"  { $response.ContentType = "image/png" }
                    ".jpg"  { $response.ContentType = "image/jpeg" }
                    ".jpeg" { $response.ContentType = "image/jpeg" }
                    ".ico"  { $response.ContentType = "image/x-icon" }
                    ".woff2"{ $response.ContentType = "font/woff2" }
                    default { $response.ContentType = "application/octet-stream" }
                }

                $response.Headers.Add("Access-Control-Allow-Origin", "*")
                $response.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate")

                $bytes = [System.IO.File]::ReadAllBytes($filePath)
                $response.ContentLength64 = $bytes.Length
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            } else {
                $response.StatusCode = 404
                $notFoundBytes = [System.Text.Encoding]::UTF8.GetBytes("404 - File Not Found")
                $response.ContentLength64 = $notFoundBytes.Length
                $response.OutputStream.Write($notFoundBytes, 0, $notFoundBytes.Length)
            }
            $response.OutputStream.Close()
        } catch {
            # Client aborted or stream closed; ignore and keep server listening
        }
    }
}
catch {
    Write-Error "Server fatal error: $_"
}
finally {
    try { $listener.Stop() } catch {}
    try { $listener.Close() } catch {}
}
