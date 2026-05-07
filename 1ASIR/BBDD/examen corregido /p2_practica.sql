-- Ejercicio 2 Saneamiento de Infraestructura --

select * from almacenes;

start transaction;
set sql_safe_updates = 0;
savepoint antesdecambiarciudad;
update almacenes set ciudad_ubicacion = replace(ciudad_ubicacion, 'Barna','Barcelona');
update almacenes set ciudad_ubicacion = replace(ciudad_ubicacion, 'VLC','Valencia');
delete from almacenes where ciudad_ubicacion is NULL; 
select ciudad_ubicacion from almacenes where ciudad_ubicacion regexp ''

