#!/bin/bash
cd /var/lib/virtuoso/db

mv /virtuoso.ini .

if [ ! -f "/.dba_pwd_set" ];
then
  virtuoso-t +wait && echo "SET password dba $DBA_PASSWORD;" | isql -u dba -p dba
  touch /.dba_pwd_set
else 
  virtuoso-t +wait &
fi

tail -f virtuoso.log
