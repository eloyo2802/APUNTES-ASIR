select * from almacenes;

-- paso 1/4 creamos la tabla tipos_gestion

create table tipos_gestion (id int auto_increment primary key,
nombre varchar(100));
start transaction;
set sql_safe_updates = 0;






set sql_safe_updates = 1;