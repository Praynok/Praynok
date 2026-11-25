-- Ratio de aciertos de caché por base de datos
SELECT datname,
       round(100.0 * blks_hit / nullif(blks_hit + blks_read, 0), 2) AS ratio_cache
FROM pg_stat_database
WHERE datname NOT LIKE 'template%'
ORDER BY ratio_cache NULLS LAST;
