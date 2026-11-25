---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

Esta consulta tarda 4 segundos en PostgreSQL 16 y debería tardar menos de 50 ms. ¿Qué pasa?

```
EXPLAIN ANALYZE SELECT * FROM orders WHERE lower(email) = 'ana@example.com';

Seq Scan on orders  (cost=0.00..185432.00 rows=25000 width=120) (actual time=0.031..4012.551 rows=3 loops=1)
  Filter: (lower((email)::text) = 'ana@example.com'::text)
  Rows Removed by Filter: 4999997
Planning Time: 0.110 ms
Execution Time: 4012.602 ms
```
