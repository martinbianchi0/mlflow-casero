DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

-- Usuario(id_usuario, nombre_usuario, email, fecha_creacion)
CREATE TABLE "Usuario" (
  id_usuario      BIGSERIAL PRIMARY KEY,
  nombre_usuario  VARCHAR(120) NOT NULL UNIQUE,
  email           VARCHAR(255) UNIQUE,
  fecha_creacion  TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Dataset(id_dataset, nombre_dataset, source, descripcion)
CREATE TABLE "Dataset" (
  id_dataset      BIGSERIAL PRIMARY KEY,
  nombre_dataset  VARCHAR(160) NOT NULL UNIQUE,
  source          VARCHAR(160),
  descripcion     TEXT
);

-- DatasetVersion(version_dataset, id_dataset, preprocesamiento, seed_split, estrategia_split, pct_train, pct_val, pct_test, path)
CREATE TABLE "DatasetVersion" (
  version_dataset   INT NOT NULL,
  id_dataset        BIGINT NOT NULL REFERENCES "Dataset"(id_dataset) ON DELETE CASCADE,
  preprocesamiento  TEXT,
  seed_split        INT,
  estrategia_split  VARCHAR(80),
  pct_train         NUMERIC(5,2),
  pct_val           NUMERIC(5,2),
  pct_test          NUMERIC(5,2),
  path              TEXT,
  PRIMARY KEY (version_dataset, id_dataset),
  CHECK (pct_train IS NULL OR pct_train BETWEEN 0 AND 100),
  CHECK (pct_val   IS NULL OR pct_val   BETWEEN 0 AND 100),
  CHECK (pct_test  IS NULL OR pct_test  BETWEEN 0 AND 100),
  CHECK (
    (pct_train IS NULL OR pct_val IS NULL OR pct_test IS NULL)
    OR ROUND((pct_train + pct_val + pct_test)::NUMERIC, 2) = 100.00
  )
);

-- Proyecto(id_proyecto, nombre_proyecto, descripcion, fecha_creacion, estado)
CREATE TABLE "Proyecto" (
  id_proyecto      BIGSERIAL PRIMARY KEY,
  nombre_proyecto  VARCHAR(160) NOT NULL UNIQUE,
  descripcion      TEXT,
  fecha_creacion   TIMESTAMP NOT NULL DEFAULT NOW(),
  estado           VARCHAR(40)
);

-- ParticipacionEnProyecto(id_usuario, id_proyecto, rol, fecha_alta, fecha_baja)
CREATE TABLE "ParticipacionEnProyecto" (
  id_proyecto  BIGINT NOT NULL REFERENCES "Proyecto"(id_proyecto) ON DELETE CASCADE,
  id_usuario   BIGINT NOT NULL REFERENCES "Usuario"(id_usuario)  ON DELETE CASCADE,
  rol          VARCHAR(60),
  fecha_alta   DATE,
  fecha_baja   DATE,
  PRIMARY KEY (id_proyecto, id_usuario),
  CHECK (fecha_baja IS NULL OR fecha_alta IS NULL OR fecha_baja >= fecha_alta)
);

-- Experimento(id_experimento, nombre_experimento, id_proyecto, objetivo, notas, fecha_creacion, seed)
CREATE TABLE "Experimento" (
  id_experimento     BIGSERIAL PRIMARY KEY,
  nombre_experimento VARCHAR(160) NOT NULL,
  id_proyecto        BIGINT NOT NULL REFERENCES "Proyecto"(id_proyecto) ON DELETE CASCADE,
  objetivo           TEXT,
  notas              TEXT,
  fecha_creacion     TIMESTAMP NOT NULL DEFAULT NOW(),
  seed               INT,
  UNIQUE (id_proyecto, nombre_experimento)
);

-- Run(id_run, numero_run, estado, tiempo_inicio, tiempo_fin, id_usuario, version_dataset, id_dataset, id_experimento)
CREATE TABLE "Run" (
  id_run          BIGSERIAL PRIMARY KEY,
  numero_run      INT NOT NULL,
  estado          VARCHAR(20) NOT NULL CHECK (estado IN ('PENDING','RUNNING','FAILED','COMPLETED', 'CANCELLED')), 
  tiempo_inicio   TIMESTAMP,
  tiempo_fin      TIMESTAMP,
  id_usuario      BIGINT REFERENCES "Usuario"(id_usuario) ON DELETE SET NULL,
  version_dataset INT,
  id_dataset      BIGINT,
  id_experimento  BIGINT NOT NULL REFERENCES "Experimento"(id_experimento) ON DELETE CASCADE,
  FOREIGN KEY (version_dataset, id_dataset)
    REFERENCES "DatasetVersion"(version_dataset, id_dataset)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE (id_experimento, numero_run),
  CHECK (tiempo_fin IS NULL OR tiempo_inicio IS NULL OR tiempo_fin >= tiempo_inicio)
);

-- Modelo(id_modelo, fecha_creacion, path_artefacto, stage, framework, algoritmo, id_run)
CREATE TABLE "Modelo" (
  id_modelo       BIGSERIAL PRIMARY KEY,
  fecha_creacion  TIMESTAMP NOT NULL DEFAULT NOW(),
  path_artefacto  TEXT,
  stage           VARCHAR(60),
  framework       VARCHAR(80),
  algoritmo       VARCHAR(120),
  id_run          BIGINT NOT NULL UNIQUE REFERENCES "Run"(id_run) ON DELETE CASCADE
);

-- Hiperparametro(nombre_hp, id_run, valor_json, dtype)
CREATE TABLE "Hiperparametro" (
  nombre_hp  VARCHAR(120) NOT NULL,
  id_run     BIGINT NOT NULL REFERENCES "Run"(id_run) ON DELETE CASCADE,
  valor_json JSONB,
  dtype      VARCHAR(40),
  PRIMARY KEY (id_run, nombre_hp)
);

-- Metrica(nombre_metrica, split, id_run, valor)
CREATE TABLE "Metrica" (
  nombre_metrica VARCHAR(120) NOT NULL,
  split          VARCHAR(10)  NOT NULL CHECK (split IN ('train','val','test')),
  id_run         BIGINT NOT NULL REFERENCES "Run"(id_run) ON DELETE CASCADE,
  valor          NUMERIC(20,8) NOT NULL,
  PRIMARY KEY (nombre_metrica, split, id_run)
);

