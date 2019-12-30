@echo off
if exist c:\progra~1\microf~1\soultrap\soultrap.exe goto skipinst
echo Running install.
echo Remember to ask for minimal install to run off of CD-ROM
echo and let it install to the default location. When prompted
echo to install DirectX, decline. DirectX is already installed.
pause
d:\setup.exe
pause
exit
:skipinst

