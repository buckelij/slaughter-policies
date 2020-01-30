# TODO
ntpd

cnmac0 - dhcp from cable modem
cnmac1 - 192.168.0.1 - DHCP leases to airport wireless network
vnet0  - 172.16.19.0/24 - guest wifi network
cnmac2 - 172.16.24.24 - DHCP lease to airtraffic

192.168.0.0/24


echo 'net.inet.ip.forwarding=1' >> /etc/sysctl.conf

rcctl enable dhcpd
rcctl set dhcpd flags cnmac1 cnmac2 vlan0

rcctl enable ntpd
rcctl start ntpd

#/usr/src is an nfs mount
mount_nfs -is 192.168.0.199:/home /usr/src

* there's an msdos fs at /dev/sd0i that you need to copy new kernels to
* Access the serial console from a mac with `sudo screen /dev/cu.usbserial* 115200`. If it's garabled or you get a resource busy error, unplug and replug the usb adaptor.
* When upgrading, copy the bsd.rd to /dev/sd0i, download all the sets to a `/bsdnew` directory and then reboot and install fro those sets.

the "tunnelbroker" dir here has a script to keep the hurricane electrice ipv6 tunnel up


#ipv6
echo 'net.inet6.ip6.forwarding=1' >> /etc/sysctl.conf
rcctl enable rtadvd
rcctl set rtadvd flags cnmac1
rcctl start rtadvd

#lol netflix doesn't allow access through hurricance eletric
rcctl disable rtadvd
rcctl stop rtadvd

=============================================================
tail -n 99999 /etc/sysctl.conf /etc/hostname.* /etc/dhcpd.conf /etc/pf.conf /etc/ntpd.conf /etc/rtadvd.conf >> README-bifrost.txt

==============================================================
==> /etc/sysctl.conf <==
net.inet.ip.forwarding=1
net.inet6.ip6.forwarding=1 

==> /etc/hostname.cnmac0 <==
inet 206.126.16.146 255.255.255.252

==> /etc/mygate <==
206.126.16.145

==> /etc/hostname.cnmac1 <==
inet 192.168.0.1 255.255.255.0 192.168.0.255
inet6 alias 2001:470:eb31::1 48

==> /etc/hostname.cnmac2 <==
inet 172.16.24.1 255.255.255.0 172.16.24.255

==> /etc/hostname.gif0 <==
tunnel 71.95.120.119 216.218.226.238
!ifconfig gif0 inet6 alias 2001:470:a:76e::2 2001:470:a:76e::1 prefixlen 128
!route -n add -inet6 default 2001:470:a:76e::1

==> /etc/hostname.vlan0 <==
parent cnmac1 vnetid 1733
172.16.19.1/24

==> /etc/dhcpd.conf <==
subnet 192.168.0.1 netmask 255.255.255.0 {
	option routers 192.168.0.1;
	option domain-name-servers 8.8.8.8;
	range 192.168.0.202 192.168.0.254;
        host synology {
                fixed-address 192.168.0.2;
                hardware ethernet 01:00:11:32:bf:b3:66;
        }
        host airport {
                fixed-address 192.168.0.12;
                hardware ethernet 6c:70:9f:d2:cd:b1;
        }
	host kibeth {
		fixed-address 192.168.0.6;
		hardware ethernet 80:e6:50:07:1f:98;
	}
	host brotherprinter {
		fixed-address 192.168.0.80;
		hardware ethernet 48:e2:44:b3:7d:2a;
	}
	host telly {
		fixed-address 192.168.0.200;
		hardware ethernet 7c:dd:90:86:5f:61;
	}
}

subnet 172.16.19.1 netmask 255.255.255.0 {
	option routers 172.16.19.1;
	option domain-name-servers 8.8.8.8;
	range 172.16.19.6 172.16.19.254;
}

subnet 172.16.24.1 netmask 255.255.255.0 {
	option routers 172.16.24.1;
	option domain-name-servers 8.8.8.8;
	range 172.16.24.6 172.16.24.10;
	host flighttracker {
		fixed-address 172.16.24.24;
		hardware ethernet d0:5f:b8:f9:bf:fd;
	}
}

==> /etc/pf.conf <==
#	$OpenBSD: pf.conf,v 1.55 2017/12/03 20:40:04 sthen Exp $
#
# See pf.conf(5) and /etc/examples/pf.conf

wan = "cnmac0"
home = "cnmac1"
guest = "vlan0"
flighttrack = "cnmac2"
v6tun = "gif0"
table <martians> { 0.0.0.0/8 10.0.0.0/8 127.0.0.0/8 169.254.0.0/16     \
                   172.16.0.0/12 192.0.0.0/24 192.0.2.0/24 224.0.0.0/3 \
                   192.168.0.0/16 198.18.0.0/15 198.51.100.0/24        \
                   203.0.113.0/24 }

set skip on lo

block return	# block stateless traffic
pass		# establish keep-state

# By default, do not permit remote connections to X11
block return in on ! lo0 proto tcp to port 6000:6010

# Port build user does not need network
block return out log proto {tcp udp} user _pbuild

# block guest access to home network
block in quick from 172.16.19.0/24 to 192.168.0.0/24

# block flighttracker access to home and guest
block in quick from 172.16.24.0/24 to 192.168.0.0/24
block in quick from 172.16.24.0/24 to 172.16.19.0/24

match in all scrub (no-df random-id max-mss 1440)
match out on egress inet from !(egress:network) to any nat-to (egress:0)
antispoof quick for { egress $home $guest $flighttrack }
block in quick on egress from <martians> to any
block return out quick on egress from any to <martians>
block all
pass out quick inet
pass out quick inet6
pass in on { $home $guest $flighttrack } inet
pass in on { $home } inet6

#tunnelbroker
pass in proto 41 from 66.220.2.74 to $wan keep state
pass out proto 41 from $wan to 66.220.2.74 keep state
pass inet proto icmp from 66.220.2.74 to $wan

#bufferbloat
queue outq on cnmac0 flows 1024 bandwidth 6M max 5M qlimit 1024 default
queue inq on cnmac1 flows 1024 bandwidth 65M max 60M qlimit 1024 default

==> /etc/ntpd.conf <==
# $OpenBSD: ntpd.conf,v 1.14 2015/07/15 20:28:37 ajacoutot Exp $
#
# See ntpd.conf(5) and /etc/examples/ntpd.conf

servers pool.ntp.org
sensor *
constraints from "https://www.google.com"

==> /etc/rtadvd.conf <==
cnmac1:\
	:addr="2001:470:eb31::":prefixlen#64:
