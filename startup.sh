#!/bin/bash
cd /var/lib/virtuoso/db

mkdir -p dumps

mv /virtuoso.ini . 2>/dev/null
chmod +x /clean-logs.sh
mv /clean-logs.sh . 2>/dev/null

if [ ! -f "/.dba_pwd_set" ];
then
  touch /sql-query.sql
  if [ "$DBA_PASSWORD" ]; then echo "user_set_password('dba', '$DBA_PASSWORD');" >> /sql-query.sql ; fi
  if [ "$SPARQL_UPDATE" = "true" ]; then echo "GRANT SPARQL_UPDATE to \"SPARQL\";" >> /sql-query.sql ; fi
  virtuoso-t +wait && isql-v -U dba -P dba < /dump_nquads_procedure.sql && isql-v -U dba -P dba < /sql-query.sql
  kill $(ps aux | grep '[v]irtuoso-t' | awk '{print $2}')
  touch /.dba_pwd_set
fi

virtuoso-t +wait +foreground

