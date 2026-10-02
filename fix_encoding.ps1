[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$path = "C:\Users\ASUS\.gemini\antigravity\scratch\portfolio-website\script.js"
$text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)

$replacements = @(
    @("â€¢", "•"),
    @("âš ï¸ ", "⚠️"),
    @("âš", "⚠️"),
    @("ðŸŽ¯", "🎯"),
    @("âœ…", "✅"),
    @("Â²", "²"),
    @("Â³", "³"),
    @("â »", "⁻"),
    @("â ´", "⁴"),
    @("â µ", "⁵"),
    @("â ¹", "⁹"),
    @("â‚‚", "₂"),
    @("â‚†", "₆"),
    @("Â²â º", "²⁺"),
    @("â‚ áµ‡", "_a^b"),
    @("â‚€", "_0")
)

foreach ($r in $replacements) {
    $text = $text.Replace($r[0], $r[1])
}

[System.IO.File]::WriteAllText($path, $text, [System.Text.Encoding]::UTF8)
Write-Output "Cleaned successfully!"
