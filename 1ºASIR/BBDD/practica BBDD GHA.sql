use gha_analytics;

-- Ejercicio 1
select * from pacientes; 
start transaction;
SET SQL_SAFE_UPDATES = 0;
DELETE p1 FROM pacientes p1
INNER JOIN pacientes p2 
WHERE p1.id > p2.id AND p1.nif = p2.nif AND p1.nombre_completo = p2.nombre_completo;
update pacientes set nif = replace(trim(nif), ' ', '');
update pacientes set nif = replace(nif, '-', '');
update pacientes set nif = replace(nif, '/', '');
update pacientes set nombre_completo = TRIM(replace(nombre_completo, '  ', ' '));
DELETE FROM pacientes WHERE nif NOT REGEXP '^[0-9]{8}[A-Z]$';
savepoint eloyo1;
ALTER TABLE pacientes MODIFY nif VARCHAR(9) NOT NULL;
ALTER TABLE pacientes ADD CONSTRAINT uq_nif UNIQUE (nif);
SET SQL_SAFE_UPDATES = 1;

rollback to eloyo1;


-- Ejercicio 2
start transaction;
select * from medicos;
set sql_safe_updates = 0;
UPDATE medicos SET num_colegiado = 'COL-28-5566' WHERE num_colegiado = '28/5566';
UPDATE medicos SET num_colegiado = 'COL-28-9900' WHERE num_colegiado = 'COL289900';
UPDATE medicos SET num_colegiado = 'COL-28-7788' WHERE num_colegiado = '28-7788';
savepoint eloyo2;
ALTER TABLE medicos ADD CONSTRAINT chk_formato_colegiado CHECK (num_colegiado REGEXP '^COL-[0-9]{2}-[0-9]{4}$');
set sql_safe_updates = 1;
rollback to eloyo2;




