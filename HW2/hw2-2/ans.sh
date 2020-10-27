#!/bin/sh

trap ctrl_c 2
ctrl_c(){
	printf "Ctrl + C pressed"
	exit
}
Main(){
	while :
	do {
		Option=$(dialog --clear --cancel-label "Exit" --menu "System Info Panel" 20 50 10 \
			1 "LOGIN RANK" 2 "PORT INFO" 3 "MOUNTPOINT INFO" \
			4 "SAVE SYSTEM INFO" 5 "LOAD SYSTEM INFO" \
			2>&1 >/dev/tty)
		result=$?
		if [ $result -eq 0 ]; then
			Select "$Option"
		elif [ $result -eq 1 ]; then
			echo "Exit"
			exit
		elif [ $result -eq 255 ]; then
			echo "Esc pressed" 1>&2
			exit
		fi
	} done
}
Select(){
	case $1 in
		1)
			LoginRank
			;;
		2)
			PortInfo
			;;
		3)
			MPInfo
			;;
		4)
			SvSysInfo
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
PortInfo(){
	sost=$(sockstat -P tcp,udp | sed '1d' | awk '{printf("%s %s_%s\n", $3, $5, $6)}')
	while :
	do {
		Option=$(dialog --cancel-label "Cancel" --menu "PORT INFO(PID and Port)" 20 50 40 $sost 2>&1 >/dev/tty)
		if [ -z $Option ]; then
			break
		elif [ $Option = "?" ]; then
			continue
		else
			detail=$(ps -p ${Option} -o user,pid,ppid,stat,%cpu,%mem,command | sed '1d' | \
				awk ' { printf("USER: %s\nPID: %s\nPPID: %s\nSTAT: %s\n%%CPU: %s\n%%MEM: %s\nCOMMAND: %s\n", $1, $2, $3, $4, $5, $6, $7) } '
				)
			dialog --title "Process Status: ${Option}" --msgbox "$detail" 20 50
		fi
	} done
}
MPInfo(){
	dfah=$(df -ah | sed '1d' | awk '{printf("%s %s\n", $1, $6)}')
	while :
	do {
		Option=$(dialog --cancel-label "Cancel" --menu "MOUNTPOINT INFO" 20 50 40 $dfah 2>&1 >/dev/tty)
		if [ -z $Option ]; then
			break
		else
			detail=$(df -ahT ${Option} | sed '1d' | \
				awk ' { printf("Filesystem: %s\nType: %s\nSize: %s\nUsed: %s\nAvail: %s\nCapacity: %s\nMounted on: %s\n", $1, $2, $3, $4, $5, $6, $7) } '
				)
			dialog --title "${Option}" --msgbox "$detail" 20 50
		fi
	} done
}
SvSysInfo(){
	physmem=$(sysctl -an hw.physmem)
	usermem=$(sysctl -an hw.usermem)
	tpm=$(echo $physmem | awk '{ val=$1+0;i=1;unit="B KBMBGBTB";while(val>=1024){val/=1024;i+=2;} } END {printf("%.2f %s\n", val, substr(unit, i, 2))}')
	fmp=$(printf "$physmem $usermem" | awk '{ printf("%.2f\n", ($1-$2)/$1*100.0) }')
	SvPath=$(dialog --title "Save to file" --clear --cancel-label "Cancel" \
		--inputbox "Enter the path:" 10 60 \
		2>&1 >/dev/tty)
	if [ -z $SvPath ]; then
		return
	elif [ $(printf '%c' "$SvPath") != "/" ]; then
		SvPath="${HOME}/${SvPath}"
	fi
	detail="This system report is generated on `date`\n\
======================================================================\n\
Hostname: `sysctl -an kern.hostname`\n\
OS Name: `sysctl -an kern.ostype`\n\
OS Release Version: `sysctl -an kern.osrelease`\n\
OS Architecture: `sysctl -an hw.machine`\n\
Processor model: `sysctl -an hw.model`\n\
Number of Processor Cores: `sysctl -an hw.ncpu`\n\
Total Physical Memory: ${tpm}\n\
Free Memory (%%): ${fmp}\n\
Total logged in users: `who | wc -l | grep -Eo '[0-9]+'`\n"
	dialog --title "System Info" --msgbox "${detail}\n\nThis output file is saved to $SvPath" 20 90
	printf "$detail" > $SvPath
}

Main