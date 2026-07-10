[CmdletBinding()]
param(
    [string]$Screens = "main_menu,job_select,character_prep,map,battle,run_settlement",
    [string]$GodotConsole = ""
)

$ErrorActionPreference = "Stop"
$CanonicalScreens = @(
    "main_menu",
    "job_select",
    "character_prep",
    "map",
    "battle",
    "run_settlement"
)

function Resolve-SelectedScreens {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "-Screens must contain at least one canonical screen."
    }

    $requested = @{}
    foreach ($item in $Value.Split(',')) {
        $screen = $item.Trim()
        if ([string]::IsNullOrWhiteSpace($screen)) {
            throw "-Screens contains an empty screen name."
        }
        if ($CanonicalScreens -notcontains $screen) {
            throw "Unknown screen '$screen'. Allowed: $($CanonicalScreens -join ',')."
        }
        $requested[$screen] = $true
    }

    return @($CanonicalScreens | Where-Object { $requested.ContainsKey($_) })
}

function Resolve-GodotConsole {
    param([string]$ExplicitPath)

    if (-not [string]::IsNullOrWhiteSpace($ExplicitPath)) {
        if (-not (Test-Path -LiteralPath $ExplicitPath -PathType Leaf)) {
            throw "Explicit Godot console path does not exist: $ExplicitPath"
        }
        return (Resolve-Path -LiteralPath $ExplicitPath).Path
    }

    $environmentPath = $env:TAIXUANZONG_GODOT_CONSOLE
    if (-not [string]::IsNullOrWhiteSpace($environmentPath)) {
        if (-not (Test-Path -LiteralPath $environmentPath -PathType Leaf)) {
            throw "TAIXUANZONG_GODOT_CONSOLE does not exist: $environmentPath"
        }
        return (Resolve-Path -LiteralPath $environmentPath).Path
    }

    $knownPath = "E:\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe"
    if (Test-Path -LiteralPath $knownPath -PathType Leaf) {
        return (Resolve-Path -LiteralPath $knownPath).Path
    }

    foreach ($commandName in @("Godot_v4.6.3-stable_win64_console.exe", "godot4_console.exe", "godot4", "godot")) {
        $command = Get-Command $commandName -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($null -ne $command) {
            return $command.Source
        }
    }

    throw "Godot console executable was not found. Use -GodotConsole or TAIXUANZONG_GODOT_CONSOLE."
}

try {
    $selectedScreens = @(Resolve-SelectedScreens -Value $Screens)
    $projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
    $godotPath = Resolve-GodotConsole -ExplicitPath $GodotConsole

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss_fff"
    $runName = "taixuanzong_visual_$timestamp`_$PID"
    $outputDirectory = Join-Path ([System.IO.Path]::GetTempPath()) $runName
    $logPath = Join-Path ([System.IO.Path]::GetTempPath()) "$runName.log"
    New-Item -ItemType Directory -Path $outputDirectory -ErrorAction Stop | Out-Null

    $screenArgument = $selectedScreens -join ','
    $godotArguments = @(
        "--path", $projectRoot,
        "--log-file", $logPath,
        "-s", "res://scripts/tests/VisualAcceptanceProbe.gd",
        "--",
        "--output-dir=$outputDirectory",
        "--screens=$screenArgument"
    )

    & $godotPath @godotArguments
    $godotExitCode = $LASTEXITCODE

    Write-Output "VISUAL_CAPTURE_LOG=$logPath"
    Write-Output "VISUAL_CAPTURE_OUTPUT_DIR=$outputDirectory"
    if ($godotExitCode -ne 0) {
        exit $godotExitCode
    }

    $expectedNames = @($selectedScreens | ForEach-Object { "$_.png" })
    $actualFiles = @(Get-ChildItem -LiteralPath $outputDirectory -File -Filter "*.png")
    $actualNames = @($actualFiles | ForEach-Object { $_.Name })
    $missingNames = @($expectedNames | Where-Object { $actualNames -notcontains $_ })
    $unexpectedNames = @($actualNames | Where-Object { $expectedNames -notcontains $_ })
    if ($missingNames.Count -gt 0 -or $unexpectedNames.Count -gt 0 -or $actualNames.Count -ne $expectedNames.Count) {
        Write-Error "PNG set mismatch. Missing: $($missingNames -join ','); unexpected: $($unexpectedNames -join ',')."
        exit 2
    }

    foreach ($screen in $selectedScreens) {
        $pngPath = Join-Path $outputDirectory "$screen.png"
        if (-not (Test-Path -LiteralPath $pngPath -PathType Leaf)) {
            Write-Error "Expected PNG is missing: $pngPath"
            exit 2
        }
        $pngFile = Get-Item -LiteralPath $pngPath
        if ($pngFile.Length -le 0) {
            Write-Error "Expected PNG is empty: $pngPath"
            exit 2
        }
        Write-Output "VISUAL_CAPTURE_PNG=$($pngFile.FullName)|$($pngFile.Length) bytes"
    }

    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
