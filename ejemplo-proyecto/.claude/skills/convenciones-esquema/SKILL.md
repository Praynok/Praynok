---
name: convenciones-esquema
description: Convenciones de nomenclatura y diseño de esquema del proyecto de facturación (tablas, columnas, índices, constraints, tipos). Úsala al escribir o revisar DDL, migraciones o modelos de datos de este repositorio.
---

# Convenciones de esquema — proyecto facturación

| Objeto | Convención | Ejemplo |
|---|---|---|
| Tabla | snake_case, plural, inglés | `invoice_lines` |
| Clave primaria | `id bigint GENERATED ALWAYS AS IDENTITY` | |
| Clave foránea (columna) | `<tabla_singular>_id` | `invoice_id` |
| Índice | `ix_<tabla>__<col1>_<col2>` | `ix_invoices__customer_id_created_at` |
| Único | `uq_<tabla>__<cols>` | `uq_customers__tax_id` |
| FK | `fk_<tabla>__<tabla_ref>` | `fk_invoice_lines__invoices` |
| Check | `ck_<tabla>__<regla>` | `ck_payments__amount_positive` |

Reglas:
- Importes: `numeric(18,4)`, nunca `float`/`real`/`money`.
- Fechas: `timestamptz` siempre; nunca `timestamp` sin zona.
- Toda tabla tiene `created_at timestamptz NOT NULL DEFAULT now()` y `updated_at`.
- Prohibido `ON DELETE CASCADE` en tablas de facturación (requisito de auditoría).
- Toda FK lleva índice en la columna referenciante.
