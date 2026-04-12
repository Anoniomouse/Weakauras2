# Fetches all embedded libraries for WeakAuras2 dev builds
# Run from the repo root: powershell -ExecutionPolicy Bypass -File fetch_libs.ps1

$ErrorActionPreference = "Stop"
$repoRoot = $PSScriptRoot

function Clone-Or-Update($url, $dest, $tag = $null) {
    if (Test-Path "$dest\.git") {
        Write-Host "  Updating $dest..."
        git -C $dest fetch --quiet
    } elseif (Test-Path $dest) {
        Write-Host "  Already exists (non-git): $dest - skipping"
        return
    } else {
        Write-Host "  Cloning $url -> $dest..."
        git clone --quiet $url $dest
    }
    if ($tag) {
        git -C $dest checkout --quiet $tag
    }
}

function Svn-Checkout($url, $dest) {
    if (Test-Path $dest) {
        Write-Host "  Updating (svn) $dest..."
        svn update --quiet $dest
    } else {
        Write-Host "  Checking out (svn) $url -> $dest..."
        svn checkout --quiet $url $dest
    }
}

function Has-Command($cmd) {
    return [bool](Get-Command $cmd -ErrorAction SilentlyContinue)
}

$hasSvn = Has-Command "svn"
if (-not $hasSvn) {
    Write-Warning "svn not found - skipping CurseForge SVN libraries. Install TortoiseSVN or SlikSVN and re-run."
}

Write-Host "`n=== WeakAuras/Libs (GitHub) ==="
Clone-Or-Update "https://github.com/wow-rp-addons/Chomp.git"      "$repoRoot/WeakAuras/Libs/Chomp"
Clone-Or-Update "https://github.com/tekkub/libdatabroker-1-1"      "$repoRoot/WeakAuras/Libs/LibDataBroker-1.1"
Clone-Or-Update "https://github.com/SafeteeWoW/LibDeflate"         "$repoRoot/WeakAuras/Libs/LibDeflate"
Clone-Or-Update "https://github.com/ascott18/LibSpellRange-1.0"    "$repoRoot/WeakAuras/Libs/LibSpellRange-1.0"
Clone-Or-Update "https://github.com/WeakAuras/LibRangeCheck-3.0"   "$repoRoot/WeakAuras/Libs/LibRangeCheck-3.0"
Clone-Or-Update "https://github.com/Stanzilla/LibCustomGlow"       "$repoRoot/WeakAuras/Libs/LibCustomGlow-1.0"
Clone-Or-Update "https://github.com/mrbuds/LibGetFrame"            "$repoRoot/WeakAuras/Libs/LibGetFrame-1.0"
Clone-Or-Update "https://github.com/emptyrivers/Archivist"         "$repoRoot/WeakAuras/Libs/Archivist" "v1.0.8"
Clone-Or-Update "https://github.com/rossnichols/LibSerialize"      "$repoRoot/WeakAuras/Libs/LibSerialize" "v1.0.0"
Clone-Or-Update "https://github.com/BigWigsMods/LibSpecialization" "$repoRoot/WeakAuras/Libs/LibSpecialization"
Clone-Or-Update "https://github.com/tukui-org/LibDispel"           "$repoRoot/WeakAuras/Libs/LibDispel"

Write-Host "  Cloning TaintLess from townlong-yak..."
Clone-Or-Update "https://www.townlong-yak.com/addons.git/taintless" "$repoRoot/WeakAuras/Libs/TaintLess"

if ($hasSvn) {
    Write-Host "`n=== WeakAuras/Libs (CurseForge SVN) ==="
    Svn-Checkout "https://repos.curseforge.com/wow/libstub/trunk"                                          "$repoRoot/WeakAuras/Libs/LibStub"
    Svn-Checkout "https://repos.curseforge.com/wow/callbackhandler/trunk/CallbackHandler-1.0"              "$repoRoot/WeakAuras/Libs/CallbackHandler-1.0"
    Svn-Checkout "https://repos.curseforge.com/wow/ace3/trunk/AceTimer-3.0"                                "$repoRoot/WeakAuras/Libs/AceTimer-3.0"
    Svn-Checkout "https://repos.curseforge.com/wow/ace3/trunk/AceSerializer-3.0"                           "$repoRoot/WeakAuras/Libs/AceSerializer-3.0"
    Svn-Checkout "https://repos.curseforge.com/wow/ace3/trunk/AceComm-3.0"                                 "$repoRoot/WeakAuras/Libs/AceComm-3.0"
    Svn-Checkout "https://repos.curseforge.com/wow/libsharedmedia-3-0/trunk/LibSharedMedia-3.0"            "$repoRoot/WeakAuras/Libs/LibSharedMedia-3.0"
    Svn-Checkout "https://repos.curseforge.com/wow/libcompress/trunk"                                      "$repoRoot/WeakAuras/Libs/LibCompress"
    Svn-Checkout "https://repos.curseforge.com/wow/libdbicon-1-0/trunk/LibDBIcon-1.0"                      "$repoRoot/WeakAuras/Libs/LibDBIcon-1.0"

    Write-Host "`n=== WeakAurasOptions/Libs (CurseForge SVN) ==="
    Svn-Checkout "https://repos.curseforge.com/wow/ace3/trunk/AceConfig-3.0"                               "$repoRoot/WeakAurasOptions/Libs/AceConfig-3.0"
    Svn-Checkout "https://repos.curseforge.com/wow/ace3/trunk/AceGUI-3.0"                                  "$repoRoot/WeakAurasOptions/Libs/AceGUI-3.0"
    Svn-Checkout "https://repos.curseforge.com/wow/ace-gui-3-0-shared-media-widgets/trunk/AceGUI-3.0-SharedMediaWidgets" "$repoRoot/WeakAurasOptions/Libs/AceGUI-3.0-SharedMediaWidgets"
    Svn-Checkout "https://repos.wowace.com/wow/libuidropdownmenu/trunk/LibUIDropDownMenu"                  "$repoRoot/WeakAurasOptions/Libs/LibUIDropDownMenu"
} else {
    Write-Warning "Skipping SVN libs (no svn installed)"
}

Write-Host "`n=== WeakAurasOptions/Libs (GitHub) ==="
Clone-Or-Update "https://github.com/WeakAuras/LibAPIAutoComplete-1.0" "$repoRoot/WeakAurasOptions/Libs/LibAPIAutoComplete-1.0"

Write-Host "`nDone. Run install.bat to copy to WoW."
