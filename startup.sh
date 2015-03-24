#!/bin/bash
cd /var/lib/virtuoso/db

mkdir dumps

mv /virtuoso.ini .

if [ ! -f "/.dba_pwd_set" ];
then
  virtuoso-t +wait && echo "SET password dba $DBA_PASSWORD;" | isql -u dba -P dba && isql -u dba -P $DBA_PASSWORD < /dump_nquads_procedure.sql
  touch /.dba_pwd_set
else 
  virtuoso-t +wait &
fi

tail -f virtuoso.log
