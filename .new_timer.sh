#!/bin/bash

work_time=$((25*60)) # set the timer length
log="$HOME/archive/2016/drafts/timer_log" # log file location
today=$(date +%F)
if [ -s $log ] # the log exists and is not empty
then # pull the last date from the log
	last_date=$(grep -oh '^....-..-..' $log | tail -1l)
fi
function end {
	end=$(date +%s) # set the end time (UNIX time)
	sudo beep -r 3 &
	echo -e "\ntimer is done"
	echo ----------------
	dif=$(($end - $begin))
	b=$(date -d @$begin +%R) # make times human-readable
	e=$(date -d @$end +%R)
	hr=$(($dif / 3600 ))
	m=$(($dif / 60))
	s=$((($dif + 60) % 60))
	elapsed="${m}m${s}s"
	total="${hr}hr${m}m"
	if [ $dif -lt "60" ] # the timer just started
	then
		echo "minimum time has not elapsed. exiting"
		exit
	elif [ -z "$last_date" ] || [ "$last_date" != "$today" ]
		# if $last_date is empty or if the last date in the log is
		# different from today's
	then # print date to log and write last timer info
		# echo $(date +%F) >> $log
		echo -e "\n$(date +%F)\t$total\t$b - $e ($elapsed)" | tee -a $log
	else # get elapsed time from last log ($l) and write timer info
		l=$(( $(tail -1l $log | sed 's/.\{10\}\t\([^hr]*\).*/\1/') * 3600 ))
		l=$(( $l + $(tail -1l $log | sed 's/.\{10\}\t[^hr]*hr\([^ms]*\)m.*/\1/') * 60 ))
		#l=$(( $l + $(tail -1l $log | sed 's/.*m\([^s]\).*/\1/') ))
		hr=$(( ($l + $dif) / 3600 ))
		m=$(( ($l + $dif) % 3600 / 60 ))
		#s=$(( ($l + $dif + 60) % 60 ))
		total="${hr}hr${m}m"
		echo -e "          \t$total\t$b - $e ($elapsed)" | tee -a $log
	fi
	exit
}
trap end INT HUP
# --------------------------------- #
if [ "$1" = "log" ]
then
	sed -n -e "/$last_date/,$ p" $log # sed from $last_date to EOF, print
	exit
elif [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ] 
then
	cat <<-here
	./tomato_timer.sh [help|log|MINUTES]
	 	help      	Prints this little help message and exits
	 	log     	Print the log info for the last day and exits
	 	version 	Prints the version information and exits
	 	MINUTES		Sets the number of minutes you want to run the timer for;
	 	        	the default is 25 minutes if omitted
	here
elif [ "$1" = "version" ] || [ "$1" = "-v" ] || [ "$1" = "--version" ]
then
	cat <<-here
		Tomato timer -- by Randy Josleyn
		v0.0
		here
		exit
fi
# --------------------------------- #
read first <<< $( grep -o '[0-9]\+' <<< $1 ) # get digits from $1
if [ -z "$1" ] # (if $1 is empty)
then # do nothing
	:
elif [ "$first" = "$1" ] # ($1 is a positive integer)
then # set the timer to $1
	work_time=$(( $first * 60 ))
else # report that you done screwed up...
	echo "invalid time---use positive integer values for minutes only"
	exit
fi
# --------------------------------- #
echo "$(($work_time/60)) minutes starts now"
echo "ETC is $(date -d ${work_time}sec +%R)"
begin=$(date +%s) # set the start time (UNIX time)
countdown=$work_time
while (($countdown > 0)) # the timer while loop
do
	countdown=$(($countdown - 1))
	sleep 1
done
end
