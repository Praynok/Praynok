-- Quién bloquea a quién (PostgreSQL 9.6+)
SELECT bloqueada.pid                 AS pid_bloqueada,
       bloqueada.usename             AS usuario_bloqueada,
       now() - bloqueada.query_start AS esperando,
       left(bloqueada.query, 100)    AS consulta_bloqueada,
       bloqueante.pid                AS pid_bloqueante,
       bloqueante.usename            AS usuario_bloqueante,
       bloqueante.state              AS estado_bloqueante,
       now() - bloqueante.xact_start AS duracion_tx_bloqueante,
       left(bloqueante.query, 100)   AS ultima_consulta_bloqueante
FROM pg_stat_activity bloqueada
JOIN LATERAL unnest(pg_blocking_pids(bloqueada.pid)) AS b(pid) ON true
JOIN pg_stat_activity bloqueante ON bloqueante.pid = b.pid
ORDER BY esperando DESC;
