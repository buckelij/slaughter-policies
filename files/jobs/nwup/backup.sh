#!/bin/sh
rsync -a --delete -e "ssh -i /home/buckelij/.ssh/id_dreamhost" nwup@nwup.church:/home/nwup /home/buckelij/nwup/backups/
ssh nwup@nwup.church -i /home/buckelij/.ssh/id_dreamhost -- mysqldump -u nwup -p`cat /home/buckelij/nwup/mysql-pass` -h mysql.nwup.church nwupchurch1 > /home/buckelij/nwup/nwupchurch1.sql
tail /home/buckelij/nwup/nwupchurch1.sql
