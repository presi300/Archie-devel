#!/bin/bash
count=0

#get a count of all files
total=$(find 2>/dev/null |wc -l)
echo "Total Files $total"

#loop through each file
find 2>/dev/null |while read f;
do
  #add one to the count for each file we find
  count=$((count+1))

  #add the file name to a log file
  echo "$f" >> /tmp/file.log
  #echo the current percent of the total number of files
  echo $(( 100*$count/$total ))

  #pipe it into 'dialog' to update progress bar
done|dialog --title "Logging All Files" --gauge "Please wait ...." 10 60 0


