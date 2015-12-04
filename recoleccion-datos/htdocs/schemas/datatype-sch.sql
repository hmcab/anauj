
CREATE SCHEMA dtsch;

CREATE TABLE dtsch.datatype (
    id serial PRIMARY KEY,
    -- data types
    dt_smallint smallint,
    dt_integer integer,
    dt_bigint bigint,
    dt_real real,
    dt_double double precision,
    dt_numeric numeric(6,4),
    dt_boolean boolean
);

INSERT INTO dtsch.datatype (dt_smallint,dt_integer,dt_bigint,dt_real,dt_double,dt_numeric,dt_boolean) VALUES 
('1','12345','123456789','3.1415','3.1415612349012341234','23.5141','true');
INSERT INTO dtsch.datatype (dt_smallint,dt_integer,dt_bigint,dt_real,dt_double,dt_numeric,dt_boolean) VALUES 
('1','12345','123456789','3.1415','3.1415612349012341234','23.5141','false');

