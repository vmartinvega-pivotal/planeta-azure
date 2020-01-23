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
cp target/planeta-azure-1.0.0.jar /usr/local/os/jar/planeta-azure-1.0.0.jar
cp jar/mssql-jdbc-7.0.0.jre8.jar /usr/local/os/jar/mssql-jdbc-7.0.0.jre8.jar
cp jar/postgresql-42.2.9.jar /usr/local/os/jar/postgresql-42.2.9.jar
```
* Copy the external.sh file
```
cp scripts/external.sh /home/gpadmin/external.sh
chmod +x /home/gpadmin/external.sh 
```
* Update the table os.ext_connection
```
psql -f scripts/install.sql
```
* Add a new connection. The type for the connection MUST be 'azure'
```
INSERT INTO os.ext_connection (type,server_name,database_name, user_name, pass) 
VALUES 
('azure', 'dynamicsplaneta-talend-sql.database.windows.net', 'Dyn_vd_talend_db', 'BitalentUser', 'PASSWORD');
INSERT INTO os.ext_connection (type,server_name,database_name, user_name, pass, port) 
VALUES 
('greenplum2', '10.18.191.80', 'planeta', 'dwpublica', 'publicarep', 5432);
```
* Get the id from the connection inserted

### External table creation

* Create external table
```
CREATE EXTERNAL WEB TABLE dweae.ext_test_vicente_azure
(
  fax_id text
)
 EXECUTE E'/home/gpadmin/external.sh CONNECTION_ID "select distinct id from fax"' ON MASTER 
 FORMAT 'text' (delimiter '|' null 'null' escape '\\') ENCODING 'UTF8';
```

```
CREATE EXTERNAL WEB TABLE dweae.ext_test_vicente_greenplum2
(
  dwc_id_usuario text
)
 EXECUTE E'/home/gpadmin/external.sh CONNECTION_ID "select dwc_id_usuario from publi_dwvdir.dwt_publicador_usuarios_acceso"' ON MASTER 
 FORMAT 'text' (delimiter '|' null 'null' escape '\\') ENCODING 'UTF8';
```

