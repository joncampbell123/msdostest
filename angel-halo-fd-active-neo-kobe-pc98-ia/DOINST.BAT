@echo off
REM dosbox.conf should have mounted the floppy images on B: and the working directory on A:
ECHO The game will need to be installed. I will run the installer.
ECHO When prompted, hit "A" and ENTER to direct installation to A:
ECHO and hit enter to accept directory A:\HALO
ECHO Use DOSBox-X disk swapping shortcut to switch floppies when prompted.
ECHO There are 4 disks, you will need to switch 3 times.
B:
INSTALL.EXE

