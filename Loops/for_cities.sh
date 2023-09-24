#!/bin/bash

for x in $(cat cities.txt);
do 
	wether=$(curl -s http://wttr.in/$x?format=3)
	echo "The wether for $wether"
done
