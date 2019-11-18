#!/bin/bash

IN_CONNECTION_ID=30
IN_QUERY=""

function trim(){
        local IN_STRING=$1
        TRIMMED_STRING=$(echo -e "${IN_STRING}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        echo $TRIMMED_STRING
}

function removeTempFile(){
        local IN_TEMP_FILE=$1

        # Removes the temp file
        if [ -f ${IN_TEMP_FILE} ]; then
                echo "DEBUG: Removing file: $IN_TEMP_FILE"
                rm ${IN_TEMP_FILE}
        fi
}

function toLowerCase() {
        echo "$1" | tr '[:upper:]' '[:lower:]'
}

TEMP_FILE="salida"
removeTempFile $TEMP_FILE

psql -c "select * from os.ext_connection where id=$IN_CONNECTION_ID" -t >> $TEMP_FILE
ROWS=$(cat salida | wc -l)

CONNECTION_TYPE=$(cat $TEMP_FILE | cut -d"|" -f2)
CONNECTION_TYPE=$(trim $CONNECTION_TYPE)

#if [[ ! -v CONNECTION_TYPE ]] || [[ -z "$CONNECTION_TYPE" ]]; then
#       echo "ERROR: The CONNECTION_TYPE cannot be empty. Exiting..."
#       exit 1
#fi

CONNECTION_TYPE=$(toLowerCase $CONNECTION_TYPE)
if ! [[ $CONNECTION_TYPE = "sqlserver" ]]
then
        echo "ERROR: The Connection Type: $CONNECTION_TYPE is not supported. Only sqlserver is supported. Existing..."
        exit 1
else
        echo "DEBUG: CONNECTION_TYPE: $CONNECTION_TYPE"
fi

SERVER=$(cat $TEMP_FILE | cut -d"|" -f3)
SERVER=$(trim $SERVER)
INSTANCE=$(cat $TEMP_FILE | cut -d"|" -f4)
INSTANCE=$(trim $INSTANCE)
PORT=$(cat $TEMP_FILE | cut -d"|" -f5)
PORT=$(trim $PORT)
DATABASE=$(cat $TEMP_FILE | cut -d"|" -f6)
DATABASE=$(trim $DATABASE)
USER=$(cat $TEMP_FILE | cut -d"|" -f7)
USER=$(trim $USER)
PASSWORD=$(cat $TEMP_FILE | cut -d"|" -f8)
PASSWORD=$(trim $PASSWROD)
echo "DEBUG: Server: $SERVER"
echo "DEBUG: Instance: $INSTANCE"
echo "DEBUG: Port: $PORT"
echo "DEBUG: Database: $DATABASE"
echo "DEBUG: User: $USER"
echo "DEBUG: Pass: *****"
removeTempFile $TEMP_FILE

#java   -classpath /usr/local/os/jar/planeta-azure-1.0.0.jar:/usr/local/os/jar/mssql-jdbc-7.0.0.jre8.jar \
#       -Xms128m \
#       -Xmx256m \
#       org.planeta.azure.App \
#       $SERVER \
#       $DATABASE \
#       $USER \
#       $PASSWORD \
#       "$QUERY"
