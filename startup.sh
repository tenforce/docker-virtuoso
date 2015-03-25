#!/bin/bash
cd /var/lib/virtuoso/db

mkdir -p dumps

mv /virtuoso.ini . 2>/dev/null

if [ ! -f "/.dba_pwd_set" ];
then
  virtuoso-t +wait && isql-v -U dba -P dba < /dump_nquads_procedure.sql && echo  "user_set_password('dba', '$DBA_PASSWORD');" | isql-v -U dba -P dba
  kill $(ps aux | grep '[v]irtuoso-t' | awk '{print $2}')
  touch /.dba_pwd_set
fi

virtuoso-t +wait +foreground

