@echo off
set ADDONS=G:\Game\World of Warcraft\_retail_\Interface\AddOns
set REPO=C:\Users\Shawn\Documents\Git\WeakAuras2

echo Copying Libs from WoW install into repo (one-time)...
for %%d in (WeakAuras WeakAurasOptions WeakAurasTemplates WeakAurasArchive WeakAurasModelPaths) do (
    if exist "%ADDONS%\%%d\Libs" (
        echo   Copying %%d\Libs...
        xcopy /E /I /Y "%ADDONS%\%%d\Libs" "%REPO%\%%d\Libs" >nul
    )
)

echo Removing installed addon folders...
for %%d in (WeakAuras WeakAurasOptions WeakAurasTemplates WeakAurasArchive WeakAurasModelPaths) do (
    if exist "%ADDONS%\%%d" (
        rmdir /S /Q "%ADDONS%\%%d"
    )
)

echo Creating junctions...
for %%d in (WeakAuras WeakAurasOptions WeakAurasTemplates WeakAurasArchive WeakAurasModelPaths) do (
    mklink /J "%ADDONS%\%%d" "%REPO%\%%d"
)

echo Done. Changes to the repo are now live in WoW immediately.
echo Just do /reload in-game after editing files.
