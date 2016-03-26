# INTRO

This script is designed for any machine to shutdown after a power failure when
attached to a power bank or battery.

For devices such as a Raspberry Pi, it serves as a perfect automated example
to shut the system down to prevent the risk of disk corruption.

This script works primarily by pinging a host (default: router @ 192.168.0.1)
that is powered directly by a wall outlet with no battery. When a power outage
occurs, that host will go down and a subsequent ping to that device will fail,
activating a timer that will shutdown the device according to the user settings.


# Configuration

[TO BE UPDATED...]


 This script shuts down the system ($interval * $ping_x) seconds after
 power loss detection.

	For example if:		$interval=5
						$ping_x=4

	Then the script will shut down the system 20 seconds (5*4)
	after it detects power loss.

	It is recommended that you keep ping intervals ($interval) low
	for higher accuracy.

	By default, the script timer is 1 hour after the first detection
	of ping failure. (e.g. Ping every 10 mins=600s for 6 times
	$interval=600, $ping_x=6)


# TROUBLESHOOTING
 Exit codes
		1   - Could not successfuly ping.

		100 - Power restored.

		105 - Lock file exists, script terminated.


