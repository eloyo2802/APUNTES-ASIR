-- 2.3 Ejercicio 3: Integridad de Rutas (RA5 - 2 puntos)
start transaction;
show tables;
select * from vehiculos;
select * from envios;
set sql_safe_updates = 0;

UPDATE envios e  -- Reasignamos esos envíos al cliente genérico (id=1)
LEFT JOIN clientes c ON e.cliente_id = c.id 
SET e.cliente_id = 1 
WHERE c.id IS NULL;

set sql_safe_updates = 1;
commit;


ALTER TABLE envios  -- Creamos la Clave Foránea para proteger la integridad futura . Cada envio TIENE QUE TENER UN ID_CLIENTE OBLIGATORIAMENTE
ADD CONSTRAINT fk_envios_clientes 
FOREIGN KEY (cliente_id) REFERENCES clientes(id);