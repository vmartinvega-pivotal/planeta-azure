#!/bin/bash

# Default values
MIN_ROWS="1000000"
PERCENTAGE="12"
COMMAND="analyze"
LOG_MESSAGES="true"
#LOG_MESSAGES="false"

while [ "$1" != "" ]; do
    case $1 in
        -m | --minrows )        shift
                                MIN_ROWS=$1
                                ;;
        -p | --percentage )     PERCENTAGE=$2
				;;
        -c | --command )        COMMAND=$2
                                ;;
        -h | --help )           echo 'Please --minrows --percentage and --command'
                                exit
                                ;;
        * )
    esac
    shift
done

function logMessage(){
        local IN_MESSAGE=$1

        if [[ $LOG_MESSAGES = "true" ]]
        then
                echo $IN_MESSAGE
        fi
}

logMessage "Value for MIN_ROWS= $MIN_ROWS"
logMessage "Value for PERCENTAGE= $PERCENTAGE"
logMessage "Value for COMMAND= $COMMAND"


TMP_TABLE="dwcontrol.tmp_segmentos"
SCHEMAS="cdlweb,dwadmin2,dwaula,dwdemo,dwdivlib,dweae,dwfocusp,dwinter,dwsic,dwsife,dwtalend,dwusi,dwusl,dwvdir,dwvinci,dwvtadirecta"

function readSkewSchema(){
        local IN_SCHEMA=$1

        echo "DEBUG: Reading skew schema: $IN_SCHEMA"

        TEMP_TABLE_SCHEMA="dwcontrol.temp_table_schema_$IN_SCHEMA"

        psql -c "DROP TABLE IF EXISTS $TEMP_TABLE_SCHEMA"

        QUERY_GET_ROWS_SCHEMA="CREATE TABLE $TEMP_TABLE_SCHEMA AS SELECT 'insert into $TMP_TABLE SELECT tableoid as id_tabla, ' || '''' || table_schema || '.' || table_name || '''' || '::text as de_tabla, gp_segment_id  as id_Segmento, COUNT(*) FROM ' || table_schema || '.' || table_name || ' GROUP BY tableoid, gp_segment_id  ORDER BY 1;' as cmd, table_catalog, table_schema, table_name, table_type FROM information_schema.tables WHERE table_name not like 'aux%' and table_name not like '%_prt%' and table_name not like 'ext%' and table_name not like 'dwv%' and table_name not like 'te_%' and table_schema = '$IN_SCHEMA' and table_type = 'BASE TABLE' ORDER BY table_type, table_name DISTRIBUTED RANDOMLY;"

        psql -c "$QUERY_GET_ROWS_SCHEMA"

        psql \
        -X \
        -c "select cmd from $TEMP_TABLE_SCHEMA" \
        --single-transaction \
        --set AUTOCOMMIT=off \
        --set ON_ERROR_STOP=on \
        --no-align \
        -t \
        --field-separator '#' \
        --quiet \
        | while read cmd ; do
                #continue
                psql -c "$cmd"
        done

        psql -c "DROP TABLE IF EXISTS $TEMP_TABLE_SCHEMA"
}


function analyzeSkew(){
        local IN_MIN_ROWS=$1
        local IN_PERCENTAGE=$2

        QUERY="select * from (select *, ((max - min) * 100)/sum as percen from (select de_tabla, min(count) as min, max(count) max, sum(count) as sum, avg(count) as avg, median(count) as median from $TMP_TABLE group by de_tabla order by de_tabla) as TABLA where sum >= $IN_MIN_ROWS) as TABLE1 where percen >= $IN_PERCENTAGE;"

        psql -c "$QUERY"
}

# Read information for the different schemas
if [[ $COMMAND = "read" ]]
then
  psql -c "DELETE FROM $TMP_TABLE"

  for schema in $(echo $SCHEMAS | tr "," "\n")
  do
        readSkewSchema $schema
  done
# Analyze the skew
elif [[ $COMMAND = "analyze" ]]
then
  analyzeSkew $MIN_ROWS $PERCENTAGE
fi