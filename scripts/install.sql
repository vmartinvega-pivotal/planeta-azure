ALTER TABLE os.ext_connection DROP CONSTRAINT ext_check;
ALTER TABLE os.ext_connection DROP CONSTRAINT ext_check_port;

ALTER TABLE os.ext_connection ADD CONSTRAINT ext_check CHECK ((type = 'oracle'::text AND database_name IS NOT NULL AND instance_name IS NULL) OR (type = 'greenplum'::text AND database_name IS NOT NULL AND instance_name IS NULL) OR (type = 'sqlserver'::text AND database_name IS NULL) OR (type = 'azure'::text AND database_name IS NOT NULL) OR (type = 'postgres'::text AND database_name IS NOT NULL AND instance_name IS NULL));
ALTER TABLE os.ext_connection ADD CONSTRAINT ext_check_port CHECK ((port > 0 AND type = 'oracle'::text) OR (port > 0 AND type = 'greenplum'::text) OR (type = 'sqlserver'::text AND port IS NULL) OR (type = 'azure'::text AND port IS NULL) OR (port > 0 AND type = 'postgres'::text));
  

CREATE EXTERNAL WEB TABLE dwtalend.ext_pdw_hotels_borrar1
(
  id TEXT
)
EXECUTE E'/home/gpadmin/external.sh 18 "SELECT Id FROM dbo.pdw_hotels"' ON MASTER 
 FORMAT 'text' (delimiter '|' null 'null' escape '\\')
ENCODING 'UTF8';
ALTER TABLE dwtalend.ext_pdw_hotels_borrar1
  OWNER TO gpadmin;
