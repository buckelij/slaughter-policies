#!/bin/sh
# builds a hostname.gif0 file and compares to /etc/hostname.gif0
# If they differ, install new hostname.gif0 and restart the interface
# Run in cron like:
#  */5 * * * * TUNNEL_UPDATE_KEY=XXX /root/tunneltracker/tunneltracker.sh


cd `dirname $0`

WAN_IP=$(ifconfig cnmac0 |grep 'inet ' | awk '{ print $2 }')

echo "tunnel $WAN_IP 216.218.226.238" > hostname.gif0.new
echo "!ifconfig gif0 inet6 alias 2001:470:a:76e::2 2001:470:a:76e::1 prefixlen 128" >> hostname.gif0.new
echo "!route -n add -inet6 default 2001:470:a:76e::1" >> hostname.gif0.new

if ! diff /etc/hostname.gif0 hostname.gif0.new >/dev/null; then
  echo "IP change to $WAN_IP. Restarting IPv6 tunnel"
  ftp -o - 'https://elijahbuck:'"$TUNNEL_UPDATE_KEY"'@ipv4.tunnelbroker.net/nic/update?hostname=480617' >/dev/null 2>&1
  cat hostname.gif0.new > /etc/hostname.gif0
  sh /etc/netstart gif0
fi

