#!/bin/bash 

echo "Welcome to the Marins's Hotel" 
sleep 1
echo "Going up"
sleep 1

for x in {1..23};
do
	if [[ $x == 13  ]]; then 
	  continue
	fi
	echo "Floor $x"
	sleep 1
done

echo "You got it, to the floor $x"

