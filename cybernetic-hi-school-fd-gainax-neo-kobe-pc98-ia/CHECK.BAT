@echo off
if exist a:\hischool goto end

imgmount b: "Cybernetic Hi-School (Disk A).hdm" -t floppy
imgmount c: "Cybernetic Hi-School (Disk B).hdm" -t floppy
imgmount d: "Cybernetic Hi-School (Disk C - Boot).hdm" -t floppy
imgmount e: "Cybernetic Hi-School (Disk D).hdm" -t floppy
a:
mkdir hischool
b:
copy /Y *.* a:\hischool\
c:
copy /Y *.* a:\hischool\
d:
copy /Y *.* a:\hischool\
e:
copy /Y *.* a:\hischool\
a:
cd \hischool
mount -u b:
mount -u c:
mount -u d:
mount -u e:

end:

