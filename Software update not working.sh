#!/bin/zsh

/usr/bin/dscacheutil -flushcache
/usr/bin/killall -HUP mDNSResponder
if [[ $(sw_vers -productVersion | awk -F'.' '{print $1}') -le 14 ]] && [[ $(sw_vers -productVersion | awk -F'.' '{print $2}') -lt 4 ]]; then
	/bin/launchctl kickstart -k system/com.apple.softwareupdated
fi

/usr/sbin/softwareupdate --list --force --include-config-data
