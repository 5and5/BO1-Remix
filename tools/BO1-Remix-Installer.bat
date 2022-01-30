@echo off

echo Black Ops 1 Remix Installer
echo.

:a
echo Do you have game_mod installed (yes/no)?
echo.
set /p ans="Enter "yes" to continue:"
echo.
if %ans%==yes (goto d)
if %ans%==Yes (goto d)
if %ans%==y (goto d)
if %ans%==no (goto b)
if %ans%==No (goto b)
if %ans%==n (goto b)
echo Your input was something other than "yes/no"
echo Try again.
echo.
goto a

:b
echo Installing game_mod will replace your iw_42.iwd removing any custom camo in there, are you sure you want to continue? (yes/no)?
echo.
set /p ans="Enter "yes" to continue:"
if %ans%==yes (goto c)
if %ans%==Yes (goto c)
if %ans%==y (goto c)
if %ans%==no (goto e)
if %ans%==No (goto e)
if %ans%==n (goto e)

:c
powershell -Command "Start-BitsTransfer -Source "https://github.com/Nukem9/LinkerMod/releases/download/v1.3.2/game_mod.zip"
powershell -Command Expand-Archive -Force -LiteralPath game_mod.zip -DestinationPath 'C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Black Ops'
powershell -Command Remove-Item -Force -Recurse "game_mod.zip"

:d
powershell -Command Start-BitsTransfer -Source "https://download1507.mediafire.com/hcqfyyyg8afg/5u4g0dxdnf7rsjw/BO1-Remix.zip"
powershell -Command Expand-Archive -Force -LiteralPath BO1-Remix.zip -DestinationPath 'C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Black Ops'
powershell -Command Remove-Item -Force -Recurse "BO1-Remix.zip"
xcopy /i "C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Black Ops\shortcut" "%USERPROFILE%\Desktop" /y

cls
echo Black Ops 1 Remix Installer
echo.
@echo ###############################################################
@echo ################ Remix Installation Complete ##################
@echo ###############################################################

timeout 5

:e
end