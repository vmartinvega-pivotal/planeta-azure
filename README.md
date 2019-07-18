# Azure External Table

Code to create a external table to access Azure sql server.

### Compile
These are the steps to compile the code.

* Compile
```
mvn clean install
```
* Copy jar files on the master host
```
cp target/planeta-azure-1.0.0.jar /usr/local/os/jar/planeta-azure-1.0.0.jar
cp jar/mssql-jdbc-7.0.0.jre8.jar /usr/local/os/jar/mssql-jdbc-7.0.0.jre8.jar
```

### App Parameters
Parameters to be set up in the app to create the external table.
* server
```
dynamicsplanetasqldev.database.windows.net
```
* database
```
dynpre_db
```
* user
```
DYNadmin
```
* password
```
*****
```
* query
```
"select distinct id from fax"
```

* Execution example
```
java -classpath /usr/local/os/jar/planeta-azure-1.0.0.jar:/usr/local/os/jar/mssql-jdbc-7.0.0.jre8.jar -Xms128m -Xmx256m org.planeta.azure.App dynamicsplanetasqldev.database.windows.net dynpre_db DYNadmin ***** "select distinct id from fax"
```


### External table creation

* Create external table
```
CREATE EXTERNAL WEB TABLE dweae.ext_test_vicente
(
  fax_id text
)
 EXECUTE E'java -classpath /usr/local/os/jar/planeta-azure-1.0.0.jar:/usr/local/os/jar/mssql-jdbc-7.0.0.jre8.jar -Xms128m -Xmx256m org.planeta.azure.App dynamicsplanetasqldev.database.windows.net dynpre_db DYNadmin ***** "select distinct id from fax"' ON MASTER 
 FORMAT 'text' (delimiter '|' null 'null' escape '\\') ENCODING 'UTF8';
```
