@echo off

mkdir \demo
cd \demo
\pkunzip -d \wing.zip
cd \demo\wing10
wsetup.exe
pause

cd \demo
\pkunzip -d \demo.zip

cd \demo\josephin
josephin

