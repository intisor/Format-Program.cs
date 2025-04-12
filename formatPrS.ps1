param($projectPath)
Write-Host "Project Path: $projectPath"
$programCsPath = Join-Path $projectPath "Program.cs"
Write-Host "Program.cs Path: $programCsPath"
$lines = Get-Content $programCsPath -ErrorAction Stop
$newLines = @()
$inSection = $false
$skipUntilBraceCloses = $false
$braceDepth = 0

foreach ($line in $lines) {
    Write-Host "Processing line: $line"
    if ($skipUntilBraceCloses) {
        $newLines += "    " + $line
        if ($line -match "{") { $braceDepth++ }
        if ($line -match "}") { $braceDepth-- }
        if ($braceDepth -eq 0) { $skipUntilBraceCloses = $false }
        continue
    }

    if ($line -match "^\s*var (builder|app) =") {
        Write-Host "Matched declaration: $line"
        $newLines += $line.TrimStart()
        $inSection = $true
    }
    elseif ($inSection -and $line -match "^\s*(builder|app)\.") {
        Write-Host "Matched chained call: $line"
        if ($line -match "=>\s*$") {
            $newLines += "    " + $line.TrimStart()
            $skipUntilBraceCloses = $true
            $braceDepth = 0
            continue
        }

        $statements = $line -split '(?<=;\s*)(?=(builder|app)\.)'
        foreach ($statement in $statements) {
            $pattern = "(?<=builder|app)\.\w+[^;]*?(?=;\s*(builder|app)\.|$)"
            $calls = [regex]::Matches($statement, $pattern) | ForEach-Object { $_.Value }
            if ($calls) {
                foreach ($call in $calls) {
                    $prefix = if ($call -match "^\s*\.") { "" } else { if ($line -match "^\s*builder\.") { "builder." } else { "app." } }
                    $formattedLine = "    " + $prefix + $call.TrimStart()
                    Write-Host "Formatted line: $formattedLine"
                    $newLines += $formattedLine
                }
            }
            else {
                $formattedLine = "    " + $statement.TrimStart()
                Write-Host "Formatted line: $formattedLine"
                $newLines += $formattedLine
            }
        }
    }
    else {
        Write-Host "No match, keeping line as-is: $line"
        $newLines += $line
        if ($line -notmatch "^\s*$") {
            $inSection = $false
        }
    }
}

$finalLines = @()
$lastLineWasBlank = $false
foreach ($line in $newLines) {
    if ($line -eq "" -and $lastLineWasBlank) { continue }
    $finalLines += $line
    $lastLineWasBlank = ($line -eq "")
}

Write-Host "Writing back to file..."
Set-Content -Path $programCsPath -Value $finalLines -ErrorAction Stop
Write-Host "Done!"