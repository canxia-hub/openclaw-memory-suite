#!/usr/bin/env pwsh
# mem-status.ps1 — Memory System Health Check Script (Windows Compatible)
# Usage: .\mem-status.ps1 [-Mode <status|search|health>] [-Keyword <字符串>] [-Month <YYYY-MM>]

param(
    [ValidateSet("status", "search", "health", "organize")]
    [string]$Mode = "health",
    [string]$Keyword = "",
    [string]$Month = "",
    [string]$Date = "",
    [switch]$Confirm
)

$ErrorActionPreference = "Stop"
$Workspace = "$env:USERPROFILE\.openclaw\workspace"
$MemoryDir = Join-Path $Workspace "memory"
$ArchiveDir = Join-Path $MemoryDir "archive\raw-backups"
$WmDir = Join-Path $Workspace ".working-memory"

# ============================================================
# Status Check
# ============================================================
function Get-MemoryStatus {
    Write-Host "`n📊 Memory System Status" -ForegroundColor Cyan
    Write-Host ("=" * 50)
    
    # Core files
    $indexFile = Join-Path $MemoryDir "INDEX.md"
    $cronFile = Join-Path $MemoryDir "CRON-JOBS.md"
    $readmeFile = Join-Path $MemoryDir "README.md"
    
    Write-Host "`n📁 Core Files:"
    @($indexFile, $cronFile, $readmeFile) | ForEach-Object {
        $exists = Test-Path $_
        $icon = if ($exists) { "✅" } else { "❌" }
        Write-Host "  $icon $(Split-Path $_ -Leaf)" -ForegroundColor $(if($exists){"Green"}else{"Red"})
    }
    
    # Monthly directories
    $months = Get-ChildItem $MemoryDir -Directory | Where-Object { $_.Name -match "^\d{4}-\d{2}$" } | Sort-Object Name
    Write-Host "`n📅 Monthly Directories ($($months.Count)):"
    $months | ForEach-Object {
        $indexInMonth = Join-Path $_.FullName "INDEX.md"
        $hasIndex = Test-Path $indexInMonth
        $fileCount = (Get-ChildItem $_.FullName -File -ErrorAction SilentlyContinue).Count
        $icon = if ($hasIndex) { "✅" } else { "⚠️ " }
        Write-Host "  $icon $($_.Name) — $fileCount files" -ForegroundColor $(if($hasIndex){"Green"}else{"Yellow"})
    }
    
    # File stats
    $allFiles = (Get-ChildItem $MemoryDir -File -Recurse -ErrorAction SilentlyContinue).Count
    $allDirs = (Get-ChildItem $MemoryDir -Directory -Recurse -ErrorAction SilentlyContinue).Count
    Write-Host "`n📈 Statistics:"
    Write-Host "  Total files: $allFiles"
    Write-Host "  Total dirs: $allDirs"
    
    # current-task
    $ctf = Join-Path $WmDir "current-task.yaml"
    if (Test-Path $ctf) {
        Write-Host "`n📋 Current Task: ✅ exists ($ctf)"
        $content = Get-Content $ctf -Raw -ErrorAction SilentlyContinue
        if ($content -match 'status:\s*(\w+)') {
            Write-Host "  Status: $($Matches[1])"
        }
        if ($content -match 'goal:\s*["'']?([\s\S]*?)["'']?$') {
            $goal = $Matches[1].Trim()
            if ($goal -eq "" -or $goal -eq '""') {
                Write-Host "  ⚠️ Goal is empty — may be stale" -ForegroundColor Yellow
            } else {
                Write-Host "  Goal: $goal"
            }
        }
    } else {
        Write-Host "`n📋 Current Task: ❌ missing" -ForegroundColor Red
    }
}

# ============================================================
# Search
# ============================================================
function Search-MemoryFiles {
    if (-not $Keyword) {
        Write-Host "❌ Missing search keyword" -ForegroundColor Red
        Write-Host "Usage: .\mem-status.ps1 -Mode search -Keyword `"text`" [-Month 2026-03] [-Date 2026-03-15]"
        return
    }
    
    $searchPath = $MemoryDir
    
    if ($Date) {
        $dayMonth = $Date.Substring(0, 7)
        $monthDir = Join-Path $MemoryDir $dayMonth
        $monthRoots = Join-Path $MemoryDir "$Date-*.md"
        if ((Test-Path $monthRoots) -or (Test-Path $monthDir)) {
            Write-Host "🔍 Searching in $dayMonth for date $Date" -ForegroundColor Cyan
            $pattern = Join-Path $MemoryDir "*$Date*.md"
            $rootFiles = Get-ChildItem $MemoryDir -Filter "*$Date*.md" -File -ErrorAction SilentlyContinue
            if ($rootFiles) {
                Select-String -Path $rootFiles.FullName -Pattern $Keyword -Encoding UTF8 |
                    ForEach-Object { "  $($_.Filename):$($_.LineNumber): $($_.Line.Trim())" }
            }
        }
    }
    
    if ($Month) {
        $monthDir = Join-Path $MemoryDir $Month
        if (Test-Path $monthDir) {
            Write-Host "🔍 Searching in $Month for: $Keyword" -ForegroundColor Cyan
            Select-String -Path "$monthDir\*.md" -Pattern $Keyword -Encoding UTF8 -ErrorAction SilentlyContinue |
                ForEach-Object { "  $($_.Filename):$($_.LineNumber): $($_.Line.Trim())" } | Select-Object -First 20
        } else {
            Write-Host "❌ Month directory not found: $monthDir" -ForegroundColor Red
        }
    } else {
        # Search all
        Write-Host "🔍 Searching all memory for: $Keyword" -ForegroundColor Cyan
        Select-String -Path "$MemoryDir\**\*.md" -Pattern $Keyword -Encoding UTF8 -ErrorAction SilentlyContinue |
            ForEach-Object { "  $(Split-Path $_.Path -Leaf):$($_.LineNumber): $($_.Line.Trim())" } | Select-Object -First 30
    }
}

# ============================================================
# Health Check
# ============================================================
function Run-HealthCheck {
    Write-Host "`n🔍 Memory System Health Check" -ForegroundColor Cyan
    Write-Host ("=" * 50)
    
    $issues = @()
    $ok = 0
    $total = 0
    
    # 1. Core files
    $total++
    if (Test-Path (Join-Path $MemoryDir "INDEX.md")) {
        Write-Host "  ✅ INDEX.md exists" -ForegroundColor Green
        $ok++
    } else {
        Write-Host "  ❌ INDEX.md missing" -ForegroundColor Red
        $issues += "INDEX.md 缺失"
    }
    
    $total++
    if (Test-Path (Join-Path $MemoryDir "CRON-JOBS.md")) {
        Write-Host "  ✅ CRON-JOBS.md exists" -ForegroundColor Green
        $ok++
    } else {
        Write-Host "  ⚠️ CRON-JOBS.md missing" -ForegroundColor Yellow
        $issues += "CRON-JOBS.md 缺失"
    }
    
    $total++
    if (Test-Path (Join-Path $MemoryDir "README.md")) {
        Write-Host "  ✅ README.md exists" -ForegroundColor Green
        $ok++
    } else {
        Write-Host "  ⚠️ README.md missing" -ForegroundColor Yellow
        $issues += "README.md 缺失"
    }
    
    # 2. current-task
    $total++
    $ctf = Join-Path $WmDir "current-task.yaml"
    if (Test-Path $ctf) {
        Write-Host "  ✅ current-task.yaml exists" -ForegroundColor Green
        $ok++
    } else {
        Write-Host "  ℹ️ current-task.yaml not found (normal if no active task)" -ForegroundColor Gray
        $ok++
    }
    
    # 3. Monthly directory index pairing
    $total++
    $months = Get-ChildItem $MemoryDir -Directory | Where-Object { $_.Name -match "^\d{4}-\d{2}$" }
    $allIndexed = $true
    
    $months | ForEach-Object {
        $mi = Join-Path $_.FullName "INDEX.md"
        if (-not (Test-Path $mi)) {
            $allIndexed = $false
        }
    }
    
    if ($allIndexed -and $months.Count -gt 0) {
        Write-Host "  ✅ All $($months.Count) monthly directories have INDEX.md" -ForegroundColor Green
        $ok++
    } elseif ($months.Count -eq 0) {
        Write-Host "  ℹ️ No monthly directories yet" -ForegroundColor Gray
        $ok++
    } else {
        Write-Host "  ⚠️ Some monthly directories missing INDEX.md" -ForegroundColor Yellow
        $issues += "部分月度目录缺少 INDEX.md"
    }
    
    # 4. Root-level scattered files
    $total++
    $rootMdFiles = Get-ChildItem $MemoryDir -File -Filter "*.md" -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notin @("INDEX.md", "README.md", "CRON-JOBS.md", "heartbeat-state.json") }
    if ($rootMdFiles.Count -gt 0) {
        Write-Host "  ⚠️ $($rootMdFiles.Count) scattered MD files in root:" -ForegroundColor Yellow
        $rootMdFiles | ForEach-Object { Write-Host "      - $($_.Name)" -ForegroundColor DarkYellow }
        $issues += "根目录有 $($rootMdFiles.Count) 个散乱文件，建议整理到月度目录"
    } else {
        Write-Host "  ✅ No scattered files in root" -ForegroundColor Green
        $ok++
    }
    
    # Summary
    Write-Host "`n" + ("=" * 50)
    $score = [math]::Round(($ok / $total) * 100)
    if ($issues.Count -eq 0) {
        Write-Host "🎉 Health: $score% ($ok/$total) — All OK" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Health: $score% ($ok/$total) — $($issues.Count) issue(s):" -ForegroundColor Yellow
        $issues | ForEach-Object { Write-Host "  - $_" }
    }
}

# ============================================================
# Organize
# ============================================================
function Organize-MemoryFiles {
    Write-Host "`n🧹 Scanning for files to organize..." -ForegroundColor Cyan
    
    $rootMdFiles = Get-ChildItem $MemoryDir -File -Filter "*.md" -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notin @("INDEX.md", "README.md", "CRON-JOBS.md", "heartbeat-state.json") }
    
    if ($rootMdFiles.Count -eq 0) {
        Write-Host "✅ No files need organizing" -ForegroundColor Green
        return
    }
    
    Write-Host "Found $($rootMdFiles.Count) file(s) to check:" -ForegroundColor Yellow
    $moved = 0
    $skipped = 0
    
    foreach ($file in $rootMdFiles) {
        # Try to extract date pattern: YYYY-MM-DD or YYYY-MM
        $basename = $file.Name
        if ($basename -match "^(\d{4}-\d{2})-\d{2}") {
            $month = $Matches[1]
            $targetDir = Join-Path $MemoryDir $month
            $targetPath = Join-Path $targetDir $basename
            
            if (-not (Test-Path $targetDir)) {
                if ($Confirm) {
                    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
                }
            }
            
            if (Test-Path $targetPath) {
                Write-Host "  ⏭️ Skip (exists): $basename → $month/" -ForegroundColor Gray
                $skipped++
                continue
            }
            
            if ($Confirm) {
                Move-Item $file.FullName $targetPath -Force
                Write-Host "  ✅ Moved: $basename → $month/" -ForegroundColor Green
            } else {
                Write-Host "  ⏳ Would move: $basename → $month/ (add -Confirm to execute)" -ForegroundColor Yellow
            }
            $moved++
        } else {
            Write-Host "  ⏭️ Unparseable (skipped): $basename" -ForegroundColor DarkGray
            $skipped++
        }
    }
    
    if ($Confirm) {
        Write-Host "`n✅ Organized: $moved, Skipped: $skipped" -ForegroundColor Green
    } else {
        Write-Host "`nℹ️ Dry-run complete. $moved files ready. Add -Confirm to execute." -ForegroundColor Cyan
    }
}

# ============================================================
# Main
# ============================================================
switch ($Mode) {
    "status"  { Get-MemoryStatus }
    "search"  { Search-MemoryFiles }
    "health"  { Run-HealthCheck }
    "organize" { Organize-MemoryFiles }
    default   {
        Write-Host "lancedb-pro mem-status.ps1"
        Write-Host ""
        Write-Host "Usage:" -ForegroundColor Cyan
        Write-Host "  .\mem-status.ps1 -Mode <status|search|health|organize>"
        Write-Host ""
        Write-Host "Examples:" -ForegroundColor Cyan
        Write-Host "  .\mem-status.ps1 -Mode health"
        Write-Host "  .\mem-status.ps1 -Mode search -Keyword `"部署`" -Month 2026-03"
        Write-Host "  .\mem-status.ps1 -Mode organize -Confirm"
    }
}
