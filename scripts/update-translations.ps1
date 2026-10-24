# rewrites MC.Xbox\lang\en.json from the strings marked in the source, then reports what each language file is missing
# -Fill adds the missing entries to each language file with the English text, so untranslated ones are easy to spot
param(
    [switch]$Fill
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$langDir = Join-Path $root "MC.Xbox\lang"
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Read-Literal([string]$run) {
    $parts = [regex]::Matches($run, 'L"((?:[^"\\]|\\.)*)"') | ForEach-Object { $_.Groups[1].Value }
    $text = $parts -join ''
    [regex]::Replace($text, '\\(u[0-9A-Fa-f]{4}|.)', {
        param($m)
        $c = $m.Groups[1].Value
        if ($c.Length -eq 5) { return [string][char][Convert]::ToInt32($c.Substring(1), 16) }
        switch ($c) { 'n' { "`n" } 't' { "`t" } default { $c } }
    })
}

function Write-Json([string]$path, [string]$name, $entries) {
    $lines = @('  "_name": ' + (Quote $name))
    foreach ($key in $entries.Keys) { $lines += '  ' + (Quote $key) + ': ' + (Quote $entries[$key]) }
    [IO.File]::WriteAllText($path, "{`n" + ($lines -join ",`n") + "`n}`n", $utf8)
}

function Quote([string]$text) {
    $escaped = $text.Replace('\', '\\').Replace('"', '\"').Replace("`n", '\n').Replace("`t", '\t').Replace("`r", '')
    '"' + $escaped + '"'
}

# keys that differ only by case are different strings, so the dictionaries have to compare exactly
function New-Map { New-Object System.Collections.Specialized.OrderedDictionary ([StringComparer]::Ordinal) }

function Read-Map([string]$path) {
    $text = Get-Content $path -Raw -Encoding UTF8
    if ($PSVersionTable.PSVersion.Major -ge 6) { return ConvertFrom-Json $text -AsHashtable }
    Add-Type -AssemblyName System.Web.Extensions
    (New-Object System.Web.Script.Serialization.JavaScriptSerializer).DeserializeObject($text)
}

$english = New-Map
$sources = Get-ChildItem (Join-Path $root "MC.Xbox") -Recurse -Include *.cpp, *.h |
    Where-Object { $_.FullName -notmatch '\\third_party\\' } | Sort-Object FullName
foreach ($file in $sources) {
    $source = [IO.File]::ReadAllText($file.FullName)
    foreach ($m in [regex]::Matches($source, '\b(?:Tr|TrFormat|TR_NOOP)\(\s*((?:L"(?:[^"\\]|\\.)*"\s*)+)')) {
        $key = Read-Literal $m.Groups[1].Value
        if (-not $english.Contains($key)) { $english[$key] = $key }
    }
}

New-Item -ItemType Directory -Force $langDir | Out-Null
Write-Json (Join-Path $langDir "en.json") "English" $english
Write-Host "en.json: $($english.Count) strings"

foreach ($file in Get-ChildItem $langDir -Filter *.json | Where-Object { $_.Name -ne "en.json" }) {
    $current = New-Map
    $name = $file.BaseName
    $parsed = Read-Map $file.FullName
    foreach ($key in $parsed.Keys) {
        if ($key -ceq "_name") { $name = $parsed[$key] } else { $current[$key] = $parsed[$key] }
    }

    $missing = @($english.Keys | Where-Object { -not $current.Contains($_) })
    $unused = @($current.Keys | Where-Object { -not $english.Contains($_) })
    Write-Host "$($file.Name): $($missing.Count) missing, $($unused.Count) no longer in the source"
    if ($Fill -and $missing.Count -gt 0) {
        foreach ($key in $missing) { $current[$key] = $key }
        Write-Json $file.FullName $name $current
    }
}
