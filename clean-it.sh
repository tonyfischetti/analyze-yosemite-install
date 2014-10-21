#!/opt/local/bin/zsh

echo "Month\tDay\tTime\tMachine\tService\tMessage" > cleaned.log
grep '^Oct' ./YosemiteInstall.log | grep -v ']:  ' | grep -v ': }' |  ./clean-log.pl >> cleaned.log

