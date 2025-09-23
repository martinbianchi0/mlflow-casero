-- load.sql
\echo 'Cargando Usuario...'
\copy "Usuario"                from 'data/Usuario.csv'                csv header

\echo 'Cargando Dataset...'
\copy "Dataset"                from 'data/Dataset.csv'                csv header

\echo 'Cargando DatasetVersion...'
\copy "DatasetVersion"         from 'data/DatasetVersion.csv'         csv header

\echo 'Cargando Proyecto...'
\copy "Proyecto"               from 'data/Proyecto.csv'               csv header

\echo 'Cargando Experimento...'
\copy "Experimento"            from 'data/Experimento.csv'            csv header

\echo 'Cargando Run...'
\copy "Run"                    from 'data/Run.csv'                    csv header

\echo 'Cargando Modelo...'
\copy "Modelo"                 from 'data/Modelo.csv'                 csv header

\echo 'Cargando Hiperparametro...'
\copy "Hiperparametro"         from 'data/Hiperparametro.csv'         csv header

\echo 'Cargando Metrica...'
\copy "Metrica"                from 'data/Metrica.csv'                csv header

\echo 'Cargando ParticipacionEnProyecto...'
\copy "ParticipacionEnProyecto"  from 'data/ParticipacionEnProyecto.csv'  csv header
