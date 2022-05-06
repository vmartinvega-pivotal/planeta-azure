# Azure External Table

Code to create a external table to access Azure sql server.

### Install
These are the steps to install the software.

* Compile the application
```
mvn clean install
```
* Copy jar files on the master host
```
cp target/planeta-azure-2.0.0.jar /usr/local/os/jar/planeta-azure-2.0.0.jar
cp jar/mssql-jdbc-7.0.0.jre8.jar /usr/local/os/jar/mssql-jdbc-7.0.0.jre8.jar
cp jar/postgresql-42.2.9.jar /usr/local/os/jar/postgresql-42.2.9.jar
cp jar/mysql-connector-java.jar /usr/local/os/jar/mysql-connector-java.jar
```
* Copy the external.sh file
```
cp scripts/external.sh /datos/carga/CTR/bin/external.sh
chmod +x /datos/carga/CTR/bin/external.sh 
```
* Update the table os.ext_connection
```
psql -f scripts/install.sql
```
* Add a new connection. The type for the connection MUST be 'azure' 'mysql' or 'greenplum'
```
INSERT INTO os.ext_connection (type,server_name,database_name, user_name, pass) 
VALUES 
('azure', 'host', 'dbname', 'user', '<password>');
INSERT INTO os.ext_connection (type,server_name,database_name, user_name, pass, port) 
VALUES 
('greenplum', 'xx.xx.xx.xx', 'dbname', 'user', '<password>', 5432);
INSERT INTO os.ext_connection (type,server_name,database_name, user_name, pass, port) 
VALUES 
('mysql', 'xx.xx.xx.xx', 'planeta', 'user', '<password>', 3306);
```
* Get the id from the connection inserted

### External table creation

* Create external table
```
CREATE EXTERNAL WEB TABLE dweae.ext_test_vicente_azure
(
  fax_id text
)
 EXECUTE E'/datos/carga/CTR/bin/external.sh CONNECTION_ID "select distinct id from fax"' ON MASTER 
 FORMAT 'text' (delimiter '|' null 'null' escape '\\') ENCODING 'UTF8';
```

* For more complex queries that cannot be easily stored in an inline string we can use another file for the external table creation, like this
```console
query="some complex query"

/datos/carga/CTR/bin/external.sh connection_id "$query"
```
A concrete example can be found inside **scripts/dwfocus_ext_dynamic_dwt_hc_mumablue.sh**

### Skew script

Columns
min. Mininum rows in a segment for a table
max. Maximum rows in a segment for a table
sum. Total rows for a table
avg. Rows average in the segments
median. Rows median in the segments
percen. Percentage of rows that represent the difference between the maximum and minimum over the total