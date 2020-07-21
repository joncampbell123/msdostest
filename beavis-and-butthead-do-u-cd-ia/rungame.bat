@echo off
echo NOTICE: Drive C does not have sufficient space.
echo ------- Install to drive D: when prompted where.
echo ------- Install to D:\beavis
e:
if not exist d:\progra~1\beavis\beavis.exe autorun.exe
d:
cd \beavis
beavis.exe

