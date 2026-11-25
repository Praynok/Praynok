-- Conexiones por estado frente al máximo configurado
SELECT state,
       count(*) AS sesiones,
       round(100.0 * count(*) / current_setting('max_connections')::int, 1) AS pct_max
FROM pg_stat_activity
WHERE backend_type = 'client backend'
GROUP BY state
ORDER BY sesiones DESC;
