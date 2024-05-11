#! /bin/bash

while getopts 'ndlc' flag; do
	case "${flag}" in 
	n) 	echo "New URL mode."
		echo "Please enter a URL to track."
		read url 
		echo "Nice job, next enter a unique alias."
		read alias
		
		#this litterally has zero error checking because i am lazy and don't wanna 

		echo "The following link will be tracked under the name $alias:  $url"
		mkdir 'webhook' >/dev/null 
		touch "webhook/trackfile.txt" >/dev/null 
		echo "$alias, $url" >> "webhook/trackfile.txt"
		mkdir "webhook/$alias" >/dev/null
		touch  "webhook/$alias/old" >/dev/null
		touch  "webhook/$alias/new" >/dev/null
		curl "$url" -s -o "webhook/$alias/old" >/dev/null
		curl "$url" -s -o "webhook/$alias/new" >/dev/null
		echo "Basic comparison should be set up."
		exit 1;
		;;

	d)	echo "Please enter the alias you wish to delete."
		read alias 
		sed -i "/$alias*/d" "./webhook/trackfile.txt" 
		rm "webhook/$alias/old" >/dev/null
		rm "webhook/$alias/new" >/dev/null
		echo "Done deleting"
		;;
	l)	echo "Listing all tracked links"
		cat "webhook/trackfile.txt";;
	c)	echo "Checking for updates"
		cat "./webhook/trackfile.txt" | while read line 
		do
			IFS=', ' read -r -a array <<< "$line";
			alias="${array[0]}";
			url="${array[1]}";

			cp "webhook/$alias/new" "webhook/$alias/old" >/dev/null
			curl "$url" -s -o "webhook/$alias/new" >/dev/null

			#time to finally get the differences 
			d=$(diff "webhook/$alias/new" "webhook/$alias/old")
			if ! [[ -z "$d" ]]; then 
				echo "$alias, has varied. Check: $url."
			fi 	
		done 
		;;
	*) 	echo "Usage: nethook -flag. Availiable flags: -n (new item), -d <alias> (delete item), -l (list items), -c (run check)"
		exit 1;;
	esac;
done



