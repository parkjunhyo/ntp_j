#! /usr/bin/env bash

### current directory and source env file
working_directory=`pwd`

### server or client selection
if [[ $# != 2 && $# != 3 && $1 = '-h' ]]
then
 echo "command usage : $0 [server/client] [server address] (server's option)"
 echo "command usage : $0 [server/client] -f (server's option) "
 echo "server's option : [bind-interface], only server configuration"
 exit
fi

### NTP server installation
apt-get install -y ntp ipcalc
sed -i '/server[[:space:]]*/d' /etc/ntp.conf
sed -i '/restrict[[:space:]]*/d' /etc/ntp.conf
echo "restrict 127.0.0.1" >> /etc/ntp.conf
echo "restrict ::1" >> /etc/ntp.conf

### update the configuration for server and client
if [[ $2 = '-f' ]]
then
 cat $working_directory/NTP_ref_server >> /etc/ntp.conf
else
 echo "server $2" >> /etc/ntp.conf
fi

### update the configuration as the server
if [[ $1 = 'server' ]]
then
 bind_if=$3
 bind_network=`ip addr show $bind_if | grep -i "\<inet\>" | awk '{print $2}'`
 bind_ip=`ipcalc $bind_network | grep -i 'address' | awk '{print $2}'`
 bind_subnet=`ipcalc $bind_network | grep -i 'netmask' | awk '{print $2}'`
 echo "restrict $bind_ip mask $bind_subnet" >> /etc/ntp.conf
fi

## system restart
service ntp restart
