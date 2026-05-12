show tables;

select * from envios;
select * from vehiculos;

select envios.id as id_envio, vehiculos.id as id_vehiculo from envios left join vehiculos on envios.vehiculo_id = vehiculos.id where vehiculos.id is NULL;

start transaction;
set sql_safe_updates = 0;
savepoint idcoche;
update envios left join vehiculos on envios.vehiculo_id = vehiculos.id set vehiculo_id = 1 where vehiculos.id is NULL;
set sql_safe_updates = 1;


