-- Создание табличного пространства
CREATE TABLESPACE ac_space OWNER postgres LOCATION 'C:\ac_space';

-- Создание БД
CREATE DATABASE aircraft_monitoring WITH OWNER = postgres ENCODING = 'UTF8' TABLESPACE = ac_space;

-- Создание роли "admin"
CREATE ROLE admin LOGIN PASSWORD 'admin';

-- Предоставление разрешения подключаться к БД
GRANT CONNECT ON DATABASE aircraft_monitoring TO admin;

-- Создание схемы "aircraft" и предоставление прав роли "admin"
CREATE SCHEMA IF NOT EXISTS aircraft AUTHORIZATION admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA aircraft TO admin;

-- Создание схемы "engines" и предоставление прав роли "admin"
CREATE SCHEMA IF NOT EXISTS engines AUTHORIZATION admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA engines TO admin;

-- Создание роли "engineer"
CREATE ROLE engineer LOGIN PASSWORD 'engineer';
-- Предоставление разрешения подключаться к БД
GRANT CONNECT ON DATABASE aircraft_monitoring TO engineer;

-- Предоставление привилегий на выполнение операций DML (SELECT, INSERT, UPDATE, DELETE) для таблиц в схемах "aircraft" и "engines"
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA aircraft TO engineer;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA engines TO engineer;

-- Создание таблиц
CREATE TABLE aircraft.aircraft_manufacturers (
  id integer generated always as identity primary key,
  manufacturer varchar NOT NULL
);

CREATE TABLE aircraft.aircraft_families (
  id integer generated always as identity primary key,
  family varchar NOT NULL,
  manufacturer_id integer
);
ALTER TABLE aircraft.aircraft_families ADD FOREIGN KEY (manufacturer_id) REFERENCES aircraft.aircraft_manufacturers (id);

CREATE TABLE aircraft.aircraft_types (
  id integer generated always as identity primary key,
  type varchar NOT NULL,
  code varchar NOT NULL,
  family_id integer
);
ALTER TABLE aircraft.aircraft_types ADD FOREIGN KEY (family_id) REFERENCES aircraft.aircraft_families (id);

CREATE TABLE aircraft.aircraft_owners (
  id integer generated always as identity primary key,
  owner varchar NOT NULL
);

CREATE TABLE aircraft.aircraft (
  id integer generated always as identity primary key,
  type_id integer,
  reg_num varchar NOT NULL UNIQUE,
  owner_id integer
);
ALTER TABLE aircraft.aircraft ADD FOREIGN KEY (type_id) REFERENCES aircraft.aircraft_types (id);
ALTER TABLE aircraft.aircraft ADD FOREIGN KEY (owner_id) REFERENCES aircraft.aircraft_owners (id);

CREATE TABLE aircraft.flights (
  id integer generated always as identity primary key,
  code varchar NOT NULL,
  dep varchar NOT NULL,
  arr varchar NOT NULL,
  owner_id integer
);
ALTER TABLE aircraft.flights ADD FOREIGN KEY (owner_id) REFERENCES aircraft.aircraft_owners (id);

CREATE TABLE aircraft.flights_history (
  id integer generated always as identity primary key,
  ac_id integer,
  flt_date date NOT NULL,
  flt_id integer,
  atd timestamp NOT NULL,
  tdown timestamp NOT NULL,
  acms_path varchar,
  qar_path varchar
);
ALTER TABLE aircraft.flights_history ADD FOREIGN KEY (ac_id) REFERENCES aircraft.aircraft (id);
ALTER TABLE aircraft.flights_history ADD FOREIGN KEY (flt_id) REFERENCES aircraft.flights (id);

CREATE TABLE engines.engine_manufacturers (
  id integer generated always as identity primary key,
  manufacturer varchar NOT NULL
);

CREATE TABLE engines.engine_families (
  id integer generated always as identity primary key,
  family varchar NOT NULL,
  manufacturer_id integer
);
ALTER TABLE engines.engine_families ADD FOREIGN KEY (manufacturer_id) REFERENCES engines.engine_manufacturers (id);

CREATE TABLE engines.engine_statuses (
  id integer generated always as identity primary key,
  status varchar NOT NULL
);

CREATE TABLE engines.engines (
  id integer generated always as identity primary key,
  family_id integer,
  part_num varchar NOT NULL,
  serial_num varchar NOT NULL,
  status_id integer
);
ALTER TABLE engines.engines ADD FOREIGN KEY (family_id) REFERENCES engines.engine_families (id);
ALTER TABLE engines.engines ADD FOREIGN KEY (status_id) REFERENCES engines.engine_statuses (id);

CREATE TABLE engines.install_positions (
  id integer generated always as identity primary key,
  pos varchar NOT NULL
);

CREATE TABLE engines.engine_positions (
  id integer generated always as identity primary key,
  engine_id integer,
  ac_id integer,
  pos_id integer,
  install_dt timestamp NOT NULL,
  remove_dt timestamp
);
ALTER TABLE engines.engine_positions ADD FOREIGN KEY (engine_id) REFERENCES engines.engines (id);
ALTER TABLE engines.engine_positions ADD FOREIGN KEY (ac_id) REFERENCES aircraft.aircraft (id);
ALTER TABLE engines.engine_positions ADD FOREIGN KEY (pos_id) REFERENCES engines.install_positions (id);

CREATE TABLE engines.engine_maintenance_codes (
  id integer generated always as identity primary key,
  code varchar NOT NULL,
  description varchar
);

CREATE TABLE engines.engine_maintenances (
  id integer generated always as identity primary key,
  engine_id integer,
  code_id integer,
  maint_dt timestamp NOT NULL,
  reason varchar,
  remarks varchar
);
ALTER TABLE engines.engine_maintenances ADD FOREIGN KEY (engine_id) REFERENCES engines.engines (id);
ALTER TABLE engines.engine_maintenances ADD FOREIGN KEY (code_id) REFERENCES engines.engine_maintenance_codes (id);
