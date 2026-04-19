# setup_dev.ps1 — One-time dev environment setup for WeakAuras2
#
# 1. Downloads all external libs (LibSerialize, LibDeflate, Ace3, etc.) into the repo.
# 2. Creates directory junctions from the WoW AddOns folder into the repo so that
#    changes are live immediately — just /reload in-game, no packaging needed.
#
# Run once from the repo root:
#   powershell -ExecutionPolicy Bypass -File setup_dev.ps1

$ErrorActionPreference = "Stop"
$repo   = $PSScriptRoot
$addons = "G:\Game\World of Warcraft\_retail_\Interface\AddOns"

$folders = @(
    "WeakAuras",
    "WeakAurasOptions",
    "WeakAurasModelPaths",
    "WeakAurasTemplates",
    "WeakAurasArchive"
)

# ── Step 1: Fetch external libraries ─────────────────────────────────────────
Write-Host "`n==> Fetching external libs..." -ForegroundColor Cyan
& "$repo\fetch_libs.ps1"

# ── Step 2: Create junctions ─────────────────────────────────────────────────
Write-Host "`n==> Creating AddOns junctions..." -ForegroundColor Cyan

foreach ($folder in $folders) {
    $target = Join-Path $repo $folder
    $link   = Join-Path $addons $folder

    if (-not (Test-Path $target)) {
        Write-Warning "Repo folder not found, skipping: $target"
        continue
    }

    if (Test-Path $link) {
        $item = Get-Item $link -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            Write-Host "  Removing existing junction: $folder"
            Remove-Item $link -Force
        } else {
            $bak = "$link.cfbak"
            Write-Host "  Backing up CurseForge install: $folder -> $folder.cfbak"
            Rename-Item $link $bak
        }
    }

    Write-Host "  Linking: $link"
    Write-Host "        -> $target"
    New-Item -ItemType Junction -Path $link -Target $target | Out-Null
}

Write-Host "`nDone. Changes to the repo are now live in WoW." -ForegroundColor Green
Write-Host "Use /reload in-game to pick up Lua changes." -ForegroundColor Green
