# tomato-timer

a simple pomodor timer

## usage
usage is pretty simple: `./tomato_timer.sh`. I alias this to `tt` for convenience. whenever I want to use it, I open a shell on a different desktop and simply start the timer.

make sure to open the script and set the directory for the log file. it defaults to `$HOME/tomato.log`

here's what you'll get if you type `./tomato_timer.sh -h`:
~~~~~~~
./tomato_timer.sh [help|log|MINUTES]
    help        prints this little help message and exits
    log         print the log info for the last day and exits
    version     prints the version information and exits
    MINUTES     sets the number of minutes to run the timer for;
                the default is 25 minutes (if omitted)
~~~~~~~

## notes
this function depends on the usage of Johnathan Nightingale's [beep](https://github.com/johnath/beep) (available, at least, in the Arch Linux repositories), which is an awesome little program to make all sorts of fancy beeping sounds. because of kernel security design, this requires sudo privileges, which means this script won't work if it's not set with NOPASSWD in the `sudoers` file. visit `beep`'s github page for some options to work around this.

alternatively, you can just find the lines that match `.*sudo beep.*$` and remove them or replace them with `echo -e '\007'`.

the log file prints statistics about completed timers into a plain text file. it tracks the total amount of time done, so you can see how much work you've done under the timers.

## TODO
here are some of the things I think might be nice (maybe I'll get to them, someday):

* integration with `todo.txt` (to print tasks completed during a timer to the log)
* independence from external programs for beeping (this is there because I can't make my system beep in a shell with the traditional method)

if you feel like doing any of these and sharing, feel free! it *is* Github, after all. enjoy!
