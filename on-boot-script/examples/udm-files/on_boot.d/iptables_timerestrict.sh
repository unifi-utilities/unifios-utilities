#!/bin/sh

## ----------------------------------------------------------------------
## Script to add/remove time-of-day restrictions on internet access for selected clients.
##
## Use DHCP reservations to encourage the selected clients to always obtain the same IP address.
##
## To install:
##   * Copy this script into /mnt/data/on_boot.d/, using something like WinSCP or SSH + vi.
##   * Grant Execute permission: chmod +x /mnt/data/on_boot.d/iptables_timerestrict.sh
##   * Run it once, to activate it (crontab entries will keep it active forever after):
##       Via SSH into UDM shell:  /mnt/data/on_boot.d/iptables_timerestrict.sh
##
## Notes:
##   * Changes to firewall rules in the Unifi Network Application will remove your restriction;
##      re-run this script to re-apply the restriction rule, or wait for the next activation/deactivation hour.
##   * To apply changes to this script (i.e. new client addresses, or changes to the time of day),
##      re-run this script manually to apply the updates, or wait for the next activation/deactivation hour.
##   * When this script activates or deactivates the blocking, it will log to /var/log/messages.
##   * While the blocking is active, you'll see one "TIMERESTRICT BLOCK: " log message per hour 
##      in /var/log/messages if any blocked clients are attempting to use the internet.
##
## Caveats:
##   * No support for wake_minute/sleep_minute - currently this only turns on/off at the top of an hour.
##   * Assumption exists that sleep_hour is always greater-than wake_hour; i.e., you can't currently 
##      have a blocked time in the middle of the day.
## ----------------------------------------------------------------------


## List all client addresses you'd like to restrict. Separate multiple with spaces.
timerestricted_addresses='192.168.1.101 192.168.1.102'  

## Hour of day to remove the restriction.
wake_hour=06

## Hour of day to activate the restriction.
sleep_hour=23



## ----------------------------------------------------------------------
## ----------------------------------------------------------------------
## ----------------------------------------------------------------------

myrule="FORWARD -i br0 -j TIMERESTRICT"

## report on blocks if rule exists
iptables -C $myrule 2>/dev/null && iptables -vL TIMERESTRICT | logger

echo "Setting up timerestrict firewall rules between $sleep_hour:00 and $wake_hour:00"

## initial setup
iptables -N TIMERESTRICT_LOGNDROP 2>/dev/null
iptables -F TIMERESTRICT_LOGNDROP 2>/dev/null
iptables -A TIMERESTRICT_LOGNDROP -m limit --limit 1/hour --limit-burst 1 -j LOG --log-prefix "TIMERESTRICT BLOCK: "
iptables -A TIMERESTRICT_LOGNDROP -j REJECT --reject-with icmp-net-prohibited

iptables -N TIMERESTRICT 2>/dev/null
iptables -F TIMERESTRICT 2>/dev/null
for ip in $timerestricted_addresses ; do
  iptables -A TIMERESTRICT -s $ip -j TIMERESTRICT_LOGNDROP
done

myrule="FORWARD -i br0 -j TIMERESTRICT"

## install or remove rule based on current time and whether the rule already exists
if [ `date +%H` -ge $sleep_hour ]; then
   logger "TIMERESTRICT: Activating sleep time"
   iptables -C $myrule 2>/dev/null || iptables -I $myrule
elif  [ `date +%H` -ge $wake_hour ]; then
   logger "TIMERESTRICT: Activating awake time"
   iptables -C $myrule 2>/dev/null && iptables -D $myrule
fi

## setup cron job to activate/deactivate on time of day
echo "00 $sleep_hour * * * `readlink -f $0`" > /etc/cron.d/iptables_timerestrict
echo "00 $wake_hour * * * `readlink -f $0`" >> /etc/cron.d/iptables_timerestrict
## Format: <minute> <hour> <day> <month> <dow> <tags and command>
/etc/init.d/crond restart

echo "Done with firewall rule setup:"
echo "-------------------------------------------------------------------"
iptables -vL FORWARD | egrep '(Chain|pkts|TIMERESTRICT)'
echo ...
iptables -vL TIMERESTRICT
iptables -vL TIMERESTRICT_LOGNDROP
echo
