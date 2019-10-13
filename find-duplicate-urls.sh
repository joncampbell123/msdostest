#/bin/bash
# In case I list a program twice by accident
cat */__DOWNLOAD__ | grep ^url= | sort | uniq -D
