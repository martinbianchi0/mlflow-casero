# mlflow casero — diseño de base de datos para trazabilidad de experimentos de ML

Diseño e implementación de un esquema **PostgreSQL** para registrar y reproducir experimentos de machine learning: quién corrió qué, sobre qué versión exacta de datos, con qué hiperparámetros y con qué resultados.

**Es un trabajo de modelado relacional, no un MLflow funcional.** El nombre es un guiño: no hay servidor, ni UI, ni tracking en vivo. Lo que hay es el modelo de datos que haría falta para sostener todo eso, con datos de prueba y consultas de explotación.

Trabajo práctico de **Bases de Datos (I312)** — Universidad de San Andrés, 2025. Nota: 9/10.

## Qué resuelve el modelo

El objetivo del esquema es que **cualquier resultado sea reconstruible**: dado un número, poder llegar a la versión de datos, la configuración y la persona que lo produjeron.

- **10 tablas:** `Usuario`, `Dataset`, `DatasetVersion`, `Proyecto`, `ParticipacionEnProyecto`, `Experimento`, `Run`, `Modelo`, `Hiperparametro`, `Metrica`.
- **La reproducibilidad está en el esquema, no en la documentación.** `DatasetVersion` guarda el preprocesamiento, la estrategia de split, la semilla y los porcentajes train/val/test, con una restricción que obliga a que **sumen 100**. Un `Run` referencia una versión de dataset por su clave compuesta, así que no puede apuntar a "el dataset" en abstracto: apunta a una versión concreta.
- **Las métricas se identifican por (nombre, split, run)**, de modo que una misma métrica no puede quedar registrada dos veces para el mismo split y es imposible guardar un número sin decir sobre qué conjunto se midió.
- **Integridad declarada:** claves primarias compuestas, clave foránea compuesta hacia `DatasetVersion`, estados de `Run` restringidos por `CHECK` (`PENDING`, `RUNNING`, `FAILED`, `COMPLETED`, `CANCELLED`), `split` limitado a `train`/`val`/`test`, y validaciones de orden temporal (una corrida no puede terminar antes de empezar).
- **Datos de prueba:** ~10.000 filas cargadas desde CSV — 1.500 corridas, 4.240 métricas, 2.940 hiperparámetros, 1.000 modelos, 100 usuarios.
- **11 consultas de explotación** en `mlflow_db/consultas/`: duración de corridas por algoritmo, mejores hiperparámetros por algoritmo, promedio de métricas, datasets con más versiones, actividad de usuarios, experimentos en proceso, entre otras.

## Cómo correrlo

Necesitás PostgreSQL y `psql`.

```bash
cd mlflow_db
cp .env.example .env        # y editá las credenciales de tu Postgres local
./initialize_db.sh          # crea la base, aplica el esquema y carga los CSV
./run_queries.sh            # corre las 11 consultas
```

`initialize_db.sh` crea la base si no existe, aplica `create_tables.sql`, carga los datos dentro de una transacción y muestra el conteo por tabla.

## Estructura

```
mlflow_db/
├── create_tables.sql        esquema completo
├── load.sql                 carga de los CSV
├── data/                    10 CSV con los datos de prueba
├── consultas/               11 consultas SQL
├── initialize_db.sh
├── run_queries.sh
└── .env.example
Informe_TP_BasesDeDatos.pdf  informe del trabajo
```

## Alcance

Es un trabajo académico. El esquema no está en uso, no fue probado a escala y no incluye índices pensados para producción ni particionado. El aporte es el modelo: qué hay que guardar para que un experimento de ML sea reproducible, y cómo forzarlo desde la base en lugar de confiar en que alguien lo documente.
