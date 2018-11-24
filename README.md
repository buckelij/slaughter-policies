### Slaughter policies for be.ideasyncratic.net

Run `bootstrap.sh` and then:

```
su root -c 'slaughter --transport=git --prefix=https://github.com/buckelij/slaughter-policies.git'
```

#### A few random notes 

*/etc/hostname.hvn0*

~~
pkg_add wide-dhcpv6
echo 'interface hvn0 { send ia-na 0; send rapid-commit; };' > /etc/dhcp6c.conf
echo 'id-assoc na {};' >> /etc/dhcp6c.conf
echo /usr/local/sbin/dhcp6c -c /etc/dhcp6c.conf hvn0 >> /etc/rc.local
~~
