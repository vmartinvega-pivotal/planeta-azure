#!/bin/bash

IN_CONNECTION_ID=$1
IN_QUERY="$2"
#LOG_MESSAGES="true"
LOG_MESSAGES="false"

function logMessage(){
        local IN_MESSAGE=$1

        if [[ $LOG_MESSAGES = "true" ]]
        then
                echo $IN_MESSAGE
        fi
}

function logMessageAndExist(){
        local IN_MESSAGE=$1

        logMessage "$IN_MESSAGE"

        exit 1
}

function trim(){
        local IN_STRING=$1
        TRIMMED_STRING=$(echo -e "${IN_STRING}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        echo $TRIMMED_STRING
}

function removeTempFile(){
        local IN_TEMP_FILE=$1

        # Removes the temp file
        if [ -f ${IN_TEMP_FILE} ]; then
                logMessage "DEBUG: Removing file: $IN_TEMP_FILE"
                rm ${IN_TEMP_FILE}
        fi
}

function toLowerCase() {
        echo "$1" | tr '[:upper:]' '[:lower:]'
}

TEMP_FILE="salida"
removeTempFile $TEMP_FILE

psql -c "select * from os.ext_connection where id=$IN_CONNECTION_ID" -t >> $TEMP_FILE
ROWS=$(cat $TEMP_FILE | wc -l)

# Checks that there is only one line
if [[ $ROWS = "1" ]]
then
        logMessageAndExist "ERROR: No connection defined for the id: $IN_CONNECTION_ID"
fi

CONNECTION_TYPE=$(cat $TEMP_FILE | cut -d"|" -f2)
CONNECTION_TYPE=$(trim $CONNECTION_TYPE)

# Checks the conneciton type
#
CONNECTION_TYPE=$(toLowerCase $CONNECTION_TYPE)
if ! [[ $CONNECTION_TYPE = "azure" ]]
then
        logMessageAndExist "ERROR: The Connection Type: $CONNECTION_TYPE is not supported. Only azure is supported. Existing..."
else
        logMessage "DEBUG: CONNECTION_TYPE: $CONNECTION_TYPE"
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
PASSWORD=$(trim $PASSWORD)

logMessage "DEBUG: Server: $SERVER"
logMessage "DEBUG: Database: $DATABASE"
logMessage "DEBUG: Query: $IN_QUERY"
logMessage "DEBUG: User: $USER"
logMessage "DEBUG: Pass: $PASSWORD"
removeTempFile $TEMP_FILE

java    -classpath /usr/local/os/jar/planeta-azure-1.0.0.jar:/usr/local/os/jar/mssql-jdbc-7.0.0.jre8.jar \
        -Xms128m \
        -Xmx256m \
        org.planeta.azure.App \
        $SERVER \
        $DATABASE \
        $USER \
        $PASSWORD \
        "$IN_QUERY"
