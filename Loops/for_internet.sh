#!/bin/bash 

# Is my internet down ? 

echo "What do you want to check?"
read check 

while true
do
	if ping -q -c 2 -W 1 $check >/dev/null;then
	  echo "Hey, it's up" 
	  break
	else 
	  echo "$check is currently down."
	fi
sleep 2
done
