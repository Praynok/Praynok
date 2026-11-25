-- Migración de ejemplo CON ERRORES a propósito, para el ejercicio del módulo 6.
-- Pide al agente revisor-migraciones que la revise y compara con la solución del curso.

ALTER TABLE invoices ADD COLUMN status varchar(20) NOT NULL DEFAULT 'pending';

CREATE INDEX invoices_status_idx ON invoices (status);

ALTER TABLE invoice_lines
  ADD CONSTRAINT invoice_lines_invoice_fk
  FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE;

UPDATE invoices SET status = 'paid'
FROM payments WHERE payments.invoice_id = invoices.id;
