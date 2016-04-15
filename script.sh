#!/bin/bash

# Outage autoshutdown script
# v 0.5.1 - Jimmy Ly

### Configuration Settings ###
subnet=192.168.0		# set network IP portion (no trailing dot, e.g. ___.___.___.---)
router=1			# Router IP's host portion. (e.g. underlined here: xxx.xxx.xxx.___)
input=no			# enables user to ping specific IP if set to yes. Pings router otherwise.
runcmd=yes			# If ping fails, run command the command below? yes/no

# Command must be enclosed by double quotes. Any double quotes inside must be escaped.
# example: cmd="echo \-\e \"Ping successful!\nSuccess time at `date +%R\ %Z`\""
cmd="shutdown -h now"

interval=600			# interval between pings in seconds
ping_x=6			# Ping a total of __ times
email=				# sends alert to this email (for more than 1 email: comma-separate, no spaces)



## Checks for file lock before executing
if [ -f "$tmp" ]; then
  exit 5
else

## Checks 'input' config, decides to automatically ping
 if [ $input = yes ]
   then read -p "Enter LAN IP to ping: $subnet." IP
   else let IP=$router
 fi

## Primary ping
## Enters ping while loop if primary ping fails, begins interation count
 echo ...Pinging $subnet.$IP.
 if ! ping -W2 -c1 $subnet.$IP &>/dev/null
 then
	tmp=.email.lockping		# name of tmp lock file, also used to create email body
	count=1
	echo \-\e "Power loss detected at `date +%R\ %Z`." > $tmp
	while [ $count -le $(( $ping_x )) ]
	do
		echo \[Ping failed\] Retrying... Attempt \#$(($count + 1))
		ping -W1 -c1 $subnet.$IP &>/dev/null

		# Module to break the out loop if successful ping
		if [ $? -eq 0 ]
		  then
		  echo >> $tmp
		  echo \-\e "Ping successful.\nPower restored at `date +%R\ %Z`" | tee -a $tmp
			## Email module
			if [ -n "$email" ]
			then
			cat ./"$tmp" > ~/alert.ping
			cat ./$tmp | mail -s "[Power] Outage restored" $email
			fi
		  if [ -f "./.email.lockping" ]; then
		  rm -f ./$tmp
		  fi
		  exit 100
		fi

		sleep $(($interval - 1))
		let count=count+1
	done

	# If ping fails after x tries
	echo >> $tmp
	echo \-\e "Host did not respond to pings.\nServer shutdown at `date +%R\ %Z`." | tee -a $tmp
		# Email module
		if [ -n "$email" ]
		then
		cat ./"$tmp" > ~/alert.ping
		fi

	if [ "$runcmd" = yes ]; then
	eval $cmd
	fi

	if [ -f "./.email.lockping" ]; then
	rm -f ./$tmp
	fi
	exit 1

# If primary ping succeeds
 else
  echo "Ping successful for $subnet.$IP."

 fi
fi
