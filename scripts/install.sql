ALTER TABLE os.ext_connection DROP CONSTRAINT ext_check;
ALTER TABLE os.ext_connection DROP CONSTRAINT ext_check_port;

ALTER TABLE os.ext_connection ADD CONSTRAINT ext_check CHECK ((type = 'oracle'::text AND database_name IS NOT NULL AND instance_name IS NULL) OR (type = 'greenplum'::text AND database_name IS NOT NULL AND instance_name IS NULL) OR (type = 'sqlserver'::text AND database_name IS NULL) OR (type = 'azure'::text AND database_name IS NOT NULL) OR (type = 'mysql'::text AND database_name IS NOT NULL));
ALTER TABLE os.ext_connection ADD CONSTRAINT ext_check_port CHECK ((port > 0 AND type = 'oracle'::text) OR (port > 0 AND type = 'greenplum'::text) OR (type = 'sqlserver'::text AND port IS NULL) OR (type = 'azure'::text AND port > 0) OR (type = 'mysql'::text AND port > 0));