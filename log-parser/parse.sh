echo "Longest Time Response"
echo
grep Completed logfile.log | sort -k5n | tail -1 | grep -B1 -Ff - logfile.log
echo
echo "Unique Endpoints Response"
echo
grep -o 'Started [A-Z]* "[^?"]*' ./logfile.log|sort|uniq -c|sort -nr|sed 's/Started //;s/$/"/;s/* //'