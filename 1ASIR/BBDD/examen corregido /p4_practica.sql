show tables;
select f_salida from envios where f_salida like '%.%';
select * from envios;

start transaction;
set sql_safe_updates = 0;
-- paso 1/3 primero saneamos
savepoint limpiarfechas;
update envios set f_salida = case
WHEN f_salida LIKE '%/%/____' THEN STR_TO_DATE(f_salida,'%d/%m/%Y')
WHEN f_salida LIKE '%-%-____' THEN STR_TO_DATE(f_salida,'%d-%m-%Y')
WHEN f_salida LIKE '____-%-%' THEN STR_TO_DATE(f_salida,'%Y-%m-%d')
WHEN f_salida LIKE '____/%/%' THEN STR_TO_DATE(f_salida,'%Y/%m/%d')
WHEN f_salida LIKE '____.%.%' THEN STR_TO_DATE(f_salida,'%Y.%m.%d')
ELSE NULL
END,
f_entrega_real = case 
when f_entrega_real LIKE '%/%/____' THEN STR_TO_DATE(f_entrega_real,'%d/%m/%Y')
WHEN f_entrega_real LIKE '%-%-____' THEN STR_TO_DATE(f_entrega_real,'%d-%m-%Y')
WHEN f_entrega_real LIKE '____-%-%' THEN STR_TO_DATE(f_entrega_real,'%Y-%m-%d')
WHEN f_entrega_real LIKE '____/%/%' THEN STR_TO_DATE(f_entrega_real,'%Y/%m/%d')
WHEN f_entrega_real LIKE '____.%.%' THEN STR_TO_DATE(f_entrega_real,'%Y.%m.%d')
ELSE NULL
END;
rollback to limpiarfechas;
-- paso 2/3 modificamos el tipo de dato de las columnas para poder restar

alter table envios add column horas_transito decimal(10,2);
alter table envios modify column f_salida timestamp;
alter table envios modify column f_entrega_real timestamp;
-- paseo 3/3
update envios set horas_transito = timestampdiff(HOUR,f_salida,f_entrega_real);
set sql_safe_updates = 0;

alter table envios modify column f_salida date;

select distinct f_salida,f_entrega_real,horas_transito from envios;