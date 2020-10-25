#!/bin/sh

trap ctrl_c 2
ctrl_c(){
	printf "Ctrl + C pressed"
	exit
}
Main(){
	Option=$(dialog --clear --cancel-label "Exit" --menu "System Info Panel" 20 50 10 \
		1 "LOGIN RANK" 2 "PORT INFO" 3 "MOUNTPOINT INFO" \
		4 "SAVE SYSTEM INFO" 5 "LOAD SYSTEM INFO" \
		2>&1 >/dev/tty)
	result=$?
	if [ $result -eq 0 ]; then
		Select "$Option"
		Main
	elif [ $result -eq 1 ]; then
		echo "Exit"
	elif [ $result -eq 255 ]; then
		echo "Esc pressed" 1>&2
	fi
}
Select(){
	case $1 in
		1)
			LoginRank
			;;
		2)
			echo "PORT INFO"
			;;
		3)
			echo "MOUNTPOINT INFO"
			;;
		4)
			echo "SAVE SYSTEM INFO"
			;;
		5)
			echo "LOAD SYSTEM INFO"
			;;
	esac
}
LoginRank(){
	Top5=$(last | sed '$d' | sed '$d' | \
		awk '{ la[$1]++ } END { for(key in la)printf("%s %s\n", key, la[key]) }' | \
		sort -r -n -k 2 | head -n 5 | \
		awk ' BEGIN { printf("Rank\tName\tTimes\n") } { printf("%s\t%s\t%s\n", NR, $1, $2) } '
		)
	dialog --title "LoginRank" --msgbox "$Top5" 20 50
}

Main