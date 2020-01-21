#!/usr/bin/env bash
#Purpose: Install and configure NTP on the SSH server
#su




#-------Function---------#
NTPConfig () {
echo "Config modification"

echo "# /etc/ntp.conf, configuration for ntpd; see ntp.conf(5) for help

driftfile /var/lib/ntp/ntp.drift

# Leap seconds definition provided by tzdata
leapfile /usr/share/zoneinfo/leap-seconds.list

statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable

# pool.ntp.org maps to about 1000 low-stratum NTP servers.  Your server will
# pick a different set every time it starts up.  Please consider joining the
# pool: <http://www.pool.ntp.org/join.html>
pool $1 iburst
pool $2 iburst
pool $3 iburst
pool $4 iburst
# Access control configuration; see /usr/share/doc/ntp-doc/html/accopt.html for
# details.  The web page <http://support.ntp.org/bin/view/Support/AccessRestrictions>
# might also be helpful.
#
# Note that 'restrict' applies to both servers and clients, so a configuration
# that might be intended to block requests from certain clients could also end
# up blocking replies from your own upstream servers.

# By default, exchange time with everybody, but don't allow configuration.
restrict -4 default kod notrap nomodify nopeer noquery limited
restrict -6 default kod notrap nomodify nopeer noquery limited

# Local users may interrogate the ntp server more closely.
restrict 127.0.0.1
restrict ::1

# Needed for adding pool entries
restrict source notrap nomodify noquery
" >> /etc/ntp.conf
}
packagecheck () {

if which $1 ; then
    echo "$1 is installed"
 else
    echo "$1 is not installed"
    apt install $1 -y
  fi
}
testconfigNTP () {
    echo "Show "
}
#-------Main---------#
packagecheck ntp
packagecheck ntpstat
packagecheck ntpdate

# Check if the ntp file exist and create a .old
if [[ -e /etc/ntp.conf ]]; then
    mv /etc/ntp.conf /etc/ntp.conf.old
    touch /etc/ntp.conf

fi

if [[ hostname -eq "ssh.lin3.actualit.info" ]]; then
    NTPServers1="time-a-g.nist.gov"
    NTPServers2="time-a-wwv.nist.gov"
    NTPServers3="time-d-b.nist.gov"
    NTPServers4="utcnist2.colorado.edu"
    NTPConfig $NTPServers1 $NTPServers2 $NTPServers3 $NTPServers4
 else
    echo "Enter the SSH Server IP [10.0.0.1x] : "
    read -r SSHServer
    NTPServers1=$SSHServer
    NTPServers2="time-a-g.nist.gov"
    NTPConfig $NTPServers1 $NTPServers2
    sed -i '/pool  iburst/d' /etc/ntp.conf
fi

service ntp restart
# Show log
echo "Show Log"
ntpq -c rv

# Confirm the synchronisation
echo "Show"
ntpstat

echo "Change timezone"
timedatectl set-timezone Europe/Zurich
timedatectl