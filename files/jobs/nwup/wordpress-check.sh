#!/bin/sh
ssh="ssh -i /home/buckelij/.ssh/id_dreamhost nwup@nwup.church -- "
wp="wp --path=/home/nwup/nwup.church"
f="elijah"
l="buck"

if `$ssh $wp core check-update | grep -q 'wordpress.*zip'`; then
  $ssh "$wp core check-update; $wp plugin status; $wp theme status" \
    | mail -s "NWUP WordPress Updates" $f.$l@gmail.com
fi
