@echo off

powershell -Command Start-BitsTransfer -Source "https://download1494.mediafire.com/8o7pbfwkmiwg/5u4g0dxdnf7rsjw/BO1-Remix.zip"
powershell -Command Expand-Archive -Force -LiteralPath BO1-Remix.zip -DestinationPath 'C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Black Ops'
powershell -Command Remove-Item -Force -Recurse "BO1-Remix.zip"

echo.
@echo ###############################################################
@echo ################ Remix Installation Complete ##################
@echo ###############################################################

timeout 5

end