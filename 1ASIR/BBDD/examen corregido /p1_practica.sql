show databases;
use logistica_global;
show tables;

-- Ejercicio 1 --

alter table empleados add column salario_neto decimal(10,2);

start transaction;
set sql_safe_updates = 0;
savepoint retencion15;
update empleados set salario_neto = cast(replace(salario_base_sucio, ' EUR','') as decimal(10,2)) * 0.85 where salario_base_sucio like '%EUR';
rollback to retencion15;
update empleados set salario_neto = cast(replace(salario_base_sucio, ' EUR','') as decimal(10,2)) * 0.82 where salario_base_sucio like '%EUR';
update empleados set salario_neto = 0 where salario_base_sucio not like '%EUR';
commit;
select salario_base_sucio,salario_neto from empleados;
set sql_safe_updates = 1;







