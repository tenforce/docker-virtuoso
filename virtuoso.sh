#!/bin/bash
cd /data

mkdir -p dumps

if [ ! -f ./virtuoso.ini ];
then
  mv /virtuoso.ini . 2>/dev/null
fi

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

if [ ! -f "/.data_loaded" ];
then
    echo "starting data loading"
    pwd="dba"
    graph="http://localhost:8890/DAV"

    if [ "$DBA_PASSWORD" ]; then pwd="$DBA_PASSWORD" ; fi
    if [ "$DEFAULT_GRAPH" ]; then graph="$DEFAULT_GRAPH" ; fi
    echo "ld_dir('toLoad', '*', '$graph');" >> /load_data.sql
    echo "rdf_loader_run();" >> /load_data.sql
    echo "exec('checkpoint');" >> /load_data.sql
    echo "WAIT_FOR_CHILDREN; " >> /load_data.sql
    echo "$(cat /load_data.sql)"
    virtuoso-t +wait && isql-v -U dba -P "$pwd" < /load_data.sql
    kill $(ps aux | grep '[v]irtuoso-t' | awk '{print $2}')
    touch /.data_loaded
fi


virtuoso-t +wait +foreground

