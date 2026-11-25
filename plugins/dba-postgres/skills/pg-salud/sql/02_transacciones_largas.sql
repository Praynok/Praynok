-- Transacciones abiertas más de 5 minutos
SELECT pid, usename, application_name, client_addr, state,
       now() - xact_start AS duracion_tx,
       left(query, 120) AS consulta
FROM pg_stat_activity
WHERE xact_start IS NOT NULL
  AND now() - xact_start > interval '5 minutes'
ORDER BY duracion_tx DESC;
