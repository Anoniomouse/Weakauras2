@echo off
set DEST=G:\Game\World of Warcraft\_retail_\Interface\AddOns

for %%d in (WeakAuras WeakAurasOptions WeakAurasTemplates WeakAurasArchive WeakAurasModelPaths) do (
    echo Installing %%d...
    xcopy /E /I /Y /EXCLUDE:exclude_libs.txt "%%d" "%DEST%\%%d" >nul
)

echo Fixing version placeholders...
powershell -Command "Get-ChildItem '%DEST%' -Recurse -Include *.toc,Init.lua,VersionCheck.lua | ForEach-Object { $c = Get-Content $_.FullName -Raw; if ($c -match '@project-version@|@project-date@|@project-revision@') { $c -replace '@project-version@','dev' -replace '@project-date@','dev' -replace '@project-revision@','0' | Set-Content $_.FullName } }"

echo Done.
