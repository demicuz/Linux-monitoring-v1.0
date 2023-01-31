#!/usr/bin/env bash

set -e

_timezone=$(timedatectl show --property=Timezone | cut -d= -f2)
_uptime=$(uptime -p)
_interface=$(netstat -i | tail -n+3 | grep -v "^lo\s" | head -n 1 | cut -d' ' -f1)
_ram=$(free --mebi | grep "^Mem:")
_space_root=$(df -BK | grep "/\$" | tr -d K)

stats="\
HOSTNAME        = $(hostname)
TIMEZONE        = $(date +"$_timezone UTC %-:::z")
USER            = $(whoami)
OS              = $(cat /etc/os-release | grep "^PRETTY_NAME=" | cut -d= -f2 | tr -d '"')
DATE            = $(date +"%d %b %Y %T")
UPTIME          = ${_uptime#"up "}
UPTIME_SEC      = $(cat /proc/uptime | awk '{print int ($1) " sec"}')
IP              = $(ifdata -pa $_interface)
MASK            = $(ifdata -pn $_interface)
GATEWAY         = $(ip r | grep "default via" | cut -d' ' -f3)
RAM_TOTAL       = $(echo $_ram | awk '{ printf("%.3f GiB", $2/1024) }')
RAM_USED        = $(echo $_ram | awk '{ printf("%.3f GiB", $3/1024) }')
RAM_FREE        = $(echo $_ram | awk '{ printf("%.3f GiB", $4/1024) }')
SPACE_ROOT      = $(echo $_space_root | awk '{ printf("%.2f MiB", $2/1024) }')
SPACE_ROOT_USED = $(echo $_space_root | awk '{ printf("%.2f MiB", $3/1024) }')
SPACE_ROOT_FREE = $(echo $_space_root | awk '{ printf("%.2f MiB", $4/1024) }')"
