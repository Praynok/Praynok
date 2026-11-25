---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

Revisa esta migración de Flyway para PostgreSQL 16. La tabla `invoices` tiene 80 millones de filas.

```sql
CREATE INDEX invoices_customer_idx ON invoices (customer_id);
ALTER TABLE invoices ALTER COLUMN amount TYPE numeric(18,4);
DELETE FROM invoices_tmp;
```
