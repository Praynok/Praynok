-- Edad de XID por base de datos (riesgo de wraparound)
SELECT datname, age(datfrozenxid) AS edad_xid,
       round(100.0 * age(datfrozenxid) / 2147483647, 1) AS pct_hasta_wraparound
FROM pg_database
ORDER BY edad_xid DESC;
