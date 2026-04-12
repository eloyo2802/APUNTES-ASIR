
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
ALTER TABLE pacientes ADD CONSTRAINT nif UNIQUE (nif);
SET SQL_SAFE_UPDATES = 1;

commit;


-- Ejercicio 2
START TRANSACTION;
select * from medicos;
SET SQL_SAFE_UPDATES = 0;

UPDATE medicos SET num_colegiado = 'COL-28-5566' WHERE num_colegiado = '28/5566';
UPDATE medicos SET num_colegiado = 'COL-28-9900' WHERE num_colegiado = 'COL289900';
UPDATE medicos SET num_colegiado = 'COL-28-7788' WHERE num_colegiado = '28-7788';

UPDATE medicos SET num_colegiado = 'COL-00-0000' WHERE num_colegiado = 'INV-999' OR num_colegiado NOT REGEXP '^COL-[0-9]{2}-[0-9]{4}$';

SAVEPOINT eloyo2;

ALTER TABLE medicos ADD CONSTRAINT chk_formato_colegiado CHECK (num_colegiado REGEXP '^COL-[0-9]{2}-[0-9]{4}$');

SET SQL_SAFE_UPDATES = 1;
COMMIT;

-- Ejercicio 3
START TRANSACTION;
select * from medicos;
set sql_safe_updates = 0;
UPDATE medicos SET especialidad_id = 1 WHERE especialidad_id NOT IN (SELECT id FROM especialidades);

DELETE FROM visitas WHERE paciente_id NOT IN (SELECT id FROM pacientes);
DELETE FROM visitas WHERE medico_id NOT IN (SELECT id FROM medicos);

SAVEPOINT eloyo3;

ALTER TABLE medicos ADD CONSTRAINT fk_medico_especialidad FOREIGN KEY (especialidad_id) REFERENCES especialidades(id);
ALTER TABLE visitas ADD CONSTRAINT fk_visita_paciente FOREIGN KEY (paciente_id) REFERENCES pacientes(id);
ALTER TABLE visitas ADD CONSTRAINT fk_visita_medico FOREIGN KEY (medico_id) REFERENCES medicos(id);
set sql_safe_updates = 1;
COMMIT;

-- Ejercicio 4
START TRANSACTION;
select * from pacientes;
set sql_safe_updates = 0;

CREATE TABLE seguros_pacientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT NOT NULL,
    num_poliza VARCHAR(50),
    estado_poliza VARCHAR(20) DEFAULT 'ACTIVA',
    CONSTRAINT fk_seguro_paciente FOREIGN KEY (paciente_id) REFERENCES pacientes(id)
);

INSERT INTO seguros_pacientes (paciente_id, num_poliza) SELECT id, num_poliza FROM pacientes WHERE num_poliza IS NOT NULL;

ALTER TABLE pacientes DROP COLUMN num_poliza;

set sql_safe_updates = 1;

COMMIT;

-- Ejercicio 5
START TRANSACTION;

ALTER TABLE visitas ADD COLUMN copago_estimado DECIMAL(10,2);

UPDATE visitas SET importe_sucio = '0.00' WHERE importe_sucio = 'Gratis';

-- En el set hice uso de la Inteligencia Artificial ya que desconocia la manera adecuada de llevar a cabo esta parte del ejercicio.
UPDATE visitas 
SET copago_estimado = CAST(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(importe_sucio, '€', ''), '$', ''), 'EUR', ''), ',', '.')) AS DECIMAL(10,2)) * 0.20;

SAVEPOINT eloyo_final;

ALTER TABLE seguros_pacientes MODIFY num_poliza VARCHAR(50) NOT NULL;
ALTER TABLE visitas MODIFY copago_estimado DECIMAL(10,2) NOT NULL;

COMMIT;

-- Ejercicio 6

START TRANSACTION;
-- En el INSERT hice uso de la Inteligencia Artificial ya que desconocia la manera adecuada de llevar a cabo esta parte del ejercicio.
INSERT IGNORE INTO pacientes (nif, nombre_completo, tel_contacto)
SELECT 
    SUBSTRING_INDEX(raw_data, '|', 1), 
    SUBSTRING_INDEX(SUBSTRING_INDEX(raw_data, '|', 2), '|', -1),
    raw_phone
FROM raw_import_visitas
WHERE SUBSTRING_INDEX(raw_data, '|', 1) NOT IN (SELECT nif FROM pacientes);

COMMIT;
