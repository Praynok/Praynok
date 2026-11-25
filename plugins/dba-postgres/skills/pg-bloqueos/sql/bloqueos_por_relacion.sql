-- Bloqueos no concedidos agrupados por relación y modo
SELECT l.relation::regclass AS relacion, l.mode, l.granted, count(*) AS n
FROM pg_locks l
WHERE l.relation IS NOT NULL
GROUP BY 1, 2, 3
HAVING bool_or(NOT l.granted)
ORDER BY n DESC;
