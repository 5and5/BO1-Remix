@echo off

echo Black Ops 1 Remix Installer
echo.

:a
echo Do you want to install on Steam or Plutonium (steam/pluto)?
echo.
set /p ans="Enter your choice to continue:"
echo.
if %ans%==steam (goto b)
if %ans%==Steam (goto b)
if %ans%==pluto (goto e)
if %ans%==Pluto (goto e)
if %ans%==Plutonium (goto e)
if %ans%==plutonium (goto e)
echo Your input was something other than "steam/pluto"
echo Try again.
echo.
goto a

:b
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
goto b

:b
echo Installing game_mod will replace your iw_42.iwd removing any custom camo in there, are you sure you want to continue? (yes/no)?
echo.
set /p ans="Enter "yes" to continue:"
if %ans%==yes (goto c)
if %ans%==Yes (goto c)
if %ans%==y (goto c)
if %ans%==no (goto a)
if %ans%==No (goto a)
if %ans%==n (goto a)

:c
powershell -Command "Start-BitsTransfer -Source "https://github.com/Nukem9/LinkerMod/releases/download/v1.3.2/game_mod.zip"
powershell -Command Expand-Archive -Force -LiteralPath game_mod.zip -DestinationPath 'C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Black Ops'
powershell -Command Remove-Item -Force -Recurse "game_mod.zip"

:d
powershell -Command Start-BitsTransfer -Source "https://github.com/5and5/BO1-Remix/releases/download/v1.7.0/BO1-Remix.zip"
powershell -Command Expand-Archive -Force -LiteralPath BO1-Remix.zip -DestinationPath 'C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Black Ops'
powershell -Command Remove-Item -Force -Recurse "BO1-Remix.zip"
xcopy /i "C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Black Ops\shortcut" "%USERPROFILE%\Desktop" /y
goto f

:e
powershell -Command Start-BitsTransfer -Source "https://github.com/5and5/BO1-Remix/releases/download/v1.7.0/BO1-Remix.zip"
powershell -Command Expand-Archive -Force -LiteralPath BO1-Remix.zip -DestinationPath '%localappdata%\Plutonium\storage\t5'
powershell -Command Remove-Item -Force -Recurse "BO1-Remix.zip"

:f
cls
echo Black Ops 1 Remix Installer
echo.
@echo ###############################################################
@echo ################ Remix Installation Complete ##################
@echo ###############################################################

timeout 5

end