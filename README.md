### Slaughter policies for be.ideasyncratic.net

Run `bootstrap.sh` and then:

```
su root -c 'slaughter --transport=git --prefix=https://github.com/buckelij/slaughter-policies.git'
```

#### A few random notes 

*/etc/hostname.em0*

~~~
inet 209.141.49.251 255.255.255.0
#router is in diff subnet, so we use 48 instead of 64
inet6 2605:6400:20:182::1 48 
#then add ndp entry slurped from tcpdump
!ndp -s 2605:6400:20::1 4c:96:14:a8:5f:f0
~~~
