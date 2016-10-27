# tomato-timer
a configurable tomato (pomodoro) timer shell script with logging
j
## usage
call the function with `./tomato-timer.sh`. by default, it sets the timer to 25 minutes and beeps when it finishes. it prints a message about the remaining time according the `$message_rate` variable. when the timer finishes, it beeps and starts a break timer. after finishing (by default) four tomato timers, it starts a longer break. all of these variables are configurable by setting their values at the top of the shell script file.

## notes
this function depends on the usage of Johnathan Nightingale's [beep](https://github.com/johnath/beep) (available, at least, in the Arch Linux repositories), which is an awesome little program to make all sorts of fancy beeping sounds. because of kernel security design, this requires sudo privileges, which means this script won't work if it's not set with NOPASSWD in the `sudoers` file. visit `beep`'s github page for some options to work around this.

alternatively, you can just find the lines that match `.*sudo beep.*$` and remove them.

the log file prints various statistics about completed timers into a plain text file. it tracks the total amount of time done, so you can see how much work you've done under the timers.

## TODO
here are some of the things I think might be nice (maybe I'll get to them, someday):

* integration with `todo.txt` (to print tasks completed during a timer to the log)
* a prettier log format
* independence from external programs for beeping

if you feel like doing any of these and sharing, feel free! it *is* Github, after all. enjoy!
