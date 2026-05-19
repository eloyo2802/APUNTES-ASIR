show tables;

select * from envios;
select * from vehiculos;

select envios.id as id_envio, envios.vehiculo_id, vehiculos.id as vehiculos_id_vehiculo from envios left join vehiculos on envios.vehiculo_id = vehiculos.id where vehiculos.id is NULL;

start transaction;
set sql_safe_updates = 0;
savepoint idcoche;
update envios left join vehiculos on envios.vehiculo_id = vehiculos.id set vehiculo_id = 1 where vehiculos.id is NULL and envios.vehiculo_id is not NULL;
rollback to idcoche;
set sql_safe_updates = 1;
commit;
alter table envios add constraint fk_envios_vehiculos foreign key (vehiculo_id) references vehiculos(id);



