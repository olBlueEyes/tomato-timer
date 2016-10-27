#!/bin/bash

#############################################
# variable definitions for the timer functions
#############################################

# set timer lengths in minutes
	work_time=25
	break_time=5
	long_break_time=15

# how many timers before a long break
	break_limit=4

# set whether the timer emits a warning beep and message
	message_on=true
	beep_on=true

# set how long in seconds the timer has to run before writing
# to the log
	min_time=60
# how much time should be left before warning time is almost up
	message_time=150

# set log location
log=$HOME/@archive/2016/@drafts/tomato.log


#############################################
# other variables (read-only)
#############################################
today=$(date +%F)
break_counter=1
work_time=$(($work_time*60))
break_time=$(($break_time*60))
long_break_time=$(($long_break_time*60))

#############################################
# log management
#############################################


# find out how many tomatoes have been completed
# check if log exists and is not empty
if [ -s $log ]; then

	last_log_date=$(grep -E '[0-9]{4}-[0-9]{2}-[0-9]{2}' $log | tail -1l)

# only print the date to log if it's different from today's
	if [ "$last_log_date" != "$today" ]; then

		echo $today >> $log
		tomato_count=0
		log_minutes=0
		log_hours=0

	fi

	# this makes sure that the date is not the last thing
	# printed in the log
	if [ "$(tail -1l $log)" != "$last_log_date" ]; then

		# as long as the date's not the last thing, this'll
		# print the last tomato_count from the log to the
		# variable
		tomato_count=$(tail -1l $log | awk -F "\t" '{ print $NF }')

		# these two variables pull the previous elapsed time from the
		# last line of the log file. each completed timer adds to
		# this variable and prints it to a new line in the log.
		read log_hours log_minutes <<< $(tail -1 $log | awk -F '[:\t]' '{ print $(NF-2), $(NF-1); }')

		# below is an alternate method with sed; vars need updating before it can be used
		# read log_hours log_minutes <<< $(tail -1 $drafts/tomato.log | sed 's/.*(\([0-9]\{2\}\):\([0-9]\{2\}\)).*/\1 \2/'

	fi

else
	# if the log doesn't exist, create it and set all the
	# necessary variables for purposes of logging
	touch $log
	echo $today >> $log
	tomato_count=0
	log_minutes=0
	log_hours=0
fi

#############################################
# what to do if interrupted
#############################################
function tomato_trap {

	# check to make sure that the break timer variables are
	# not empty. if they are, then no further action is needed
	# and so exit.
	if [ ! -z $b_ctdn ] || [ ! -z $long_break_ctd ]; then
		exit

	# don't write to the log if the minimum time has not
	# passed.
	elif [ $(($work_time-$countdown)) -le $min_time ]; then
		echo -e "\nless than the minimum log time passed. exiting."
		exit

	# else, get the ending time and write the info to the log
	else

		tomato_end

		exit

	fi
}

trap tomato_trap INT HUP

#############################################
# timer functions
#############################################

# This puts the main tomato timer into action
function tomato_time {

	countdown=$work_time

	read start start_time <<< $(date '+%s %R')

	echo "$(($countdown/60)) minutes starts now"
	echo "estimated completion time: $(date -d @$(( $(date +%s) + $countdown )) +%R)"

	while [ $countdown -gt 0 ]; do

		countdown=$(($countdown-1))
		sleep 1

		if [ $countdown = $message_time ]; then
			if [ "$beep_on" = "true" ]; then
				sudo beep -l 125 -d 500 -r 5 &
			fi
			if [ "$message_on" = "true" ]; then
				if [ $(($countdown/60)) = 1 ]; then
					echo "1 minute left"
				else
					echo "$(($message_time/60)) minutes left"
				fi
			fi
		fi

	done

	if [ $countdown = 0 ]; then
		if [ "$beep_on" = "true" ]; then
			sudo beep -f 660 -n -f 440 -l 500 &
		fi
		tomato_end
		if [ "$break_counter" = "$break_limit" ]; then
			break_counter=1
			long_break_time
		else
			break_counter=$(($break_counter+1))
			break_time
		fi
	fi

}

# this writes to the log and ends the timer (used in
# tomato_time and clean_up)
function tomato_end {

	# $end is UNIX time, $end_time is time in hh:mm format
	# $end is for calculating start and end difference
	# $end_time is used to print the time to the log
	read end end_time <<< $(date '+%s %R')

	tomato_count=$(($tomato_count+1))

	np_e_m=$((($end-$start)/60))

	total_hr=$(printf "%02d" $(( 10#$log_hours + ($np_e_m + 10#$log_minutes)/60 )) )
	total_min=$(printf "%02d" $(( (10#$log_minutes + $np_e_m + 60)%60 )) )

	elapsed_minutes=$(printf "%02d" $((($end-$start)/60)))
	elapsed_seconds=$(printf "%02d" $((($end-$start)%60)))

	echo -e "\t$start_time - $end_time ($elapsed_minutes:$elapsed_seconds)\t$total_hr:$total_min\t$tomato_count" | tee -a $log

	# write the latest log totals to the vars
	read log_minutes log_hours <<< $(tail -1 $log | awk -F '[:\t]' '{ print $(NF-2), $(NF-1); }')

}

function break_time {

	echo "short break..."
	b_ctdn=$break_time
	while [ $b_ctdn -gt 0 ]; do
		b_ctdn=$(($b_ctdn-1))
		sleep 1
	done
	if [ $b_ctdn == 0 ]; then
		if [ "$beep_on" = "true" ]; then
			sudo beep -f 440 -n -f 660 -l 500 &
		fi
		echo "time to get back to work..."
		unset b_ctdn
		tomato_time
	fi
}

# call the long break after $break_limit tomatoes
function long_break_time {
	echo "long break"
	l_b_ctdn=$long_break_time
	while [ $l_b_ctdn -gt 0 ]; do
		l_b_ctdn=$(($l_b_ctdn-1))
		sleep 1
	done
	if [ $l_b_ctdn == 0 ]; then
		if [ "$beep_on" = "true" ]; then
			sudo beep -f 660 -n -f 440 -n -f 293.33 -d 50 -n -f 440 -l 500 &
		fi
		echo "time to get back to work..."
		unset l_b_ctdn
		tomato_time
	fi
}

#############################################
# check if the running timers should be killed
#############################################
if [ ""$1"" != "" ] || [ "$1" = "stop" ] || [ "$1" = "kill" ] || [ "$1" = "end" ]; then
	killall tomato_timer.sh
fi
if [ $message_time -gt $work_time ]; then
	>&2 echo "WARNING: message rate is slower than the timer. changing rate to one minute."
	message_time=60
fi
#############################################
# the actual program
#############################################

tomato_time &
