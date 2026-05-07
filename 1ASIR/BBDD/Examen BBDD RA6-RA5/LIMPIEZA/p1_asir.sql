show databases;
use logistica_global;
show tables;


-- 2.1 Ejercicio 1: Crédito de Clientes(RA5 - 2 ptos)
explain empleados;
-- Extrae el valor numérico y APLICALE un incremento del 15% de IRPF.
start transaction;
savepoint eloyo1;
set sql_safe_updates = 0;
UPDATE empleados SET salario_base_sucio = CAST(TRIM(SUBSTRING_INDEX(salario_base_sucio, ' ', 1)) AS DECIMAL(10,2)) * 0.85; -- Extrae el valor numérico y aplícale un incremento del 15% de IRPF.
select * from empleados;
rollback to eloyo1;  -- Utilizando ROLLBACK y un SAVEPOINT, deshaz el cambio anterior y, sin cerrar la transacción, aplica el incremento del 18% de IRPF.
UPDATE empleados SET salario_base_sucio = CAST(TRIM(SUBSTRING_INDEX(salario_base_sucio, ' ', 1)) AS DECIMAL(10,2)) * 0.82;
set sql_safe_updates = 1;
commit;

ALTER TABLE empleados ADD COLUMN salario_neto DECIMAL(10,2);











