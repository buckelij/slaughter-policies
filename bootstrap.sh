#!/bin/sh

if test  `whoami` != "root"; then
  su root -c "$0"
  exit
fi 

cd /root

export PKG_PATH=http://ftp5.usa.openbsd.org/pub/OpenBSD/`uname -r`/packages/amd64/
pkg_add -I p5-libwww
pkg_add -I git

ftp http://search.cpan.org/CPAN/authors/id/M/MJ/MJD/Text-Template-1.46.tar.gz
rm -rf Text-Template-1.46
tar xvfz Text-Template-1.46.tar.gz
cd Text-Template-1.46
perl Makefile.PL
make install
rm -f Text-Template-1.46.tar.gz

ftp http://search.cpan.org/CPAN/authors/id/S/SK/SKX/App-Slaughter-3.0.5.tar.gz
rm -rf App-Slaughter-3.0.5
tar xvfz App-Slaughter-3.0.5.tar.gz
cd App-Slaughter-3.0.5
perl Makefile.PL
make install
rm -f App-Slaughter-3.0.5.tar.gz
