use logistica_global ;
show tables;
select * from mantenimientos_flota;

-- Ejercicio 1: La tabla mantenimientos_flota tiene el campo coste_reparacion como texto (ej: 450 Euros).

ALTER TABLE mantenimientos_flota ADD COLUMN coste_eur DECIMAL(10,2); -- AÑADIR una COLUMNA coste_eur de tipo DECIMAL(10,2).

-- Extrae el valor numérico y APLICALE un incremento del 21% de IVA.
start transaction;
savepoint antes_del_calculo;
set sql_safe_updates = 0;
UPDATE mantenimientos_flota SET coste_eur = CAST(TRIM(REPLACE(coste_reparacion, 'Euros', '')) AS DECIMAL(10,2)) * 1.21; -- Extrae el valor numérico y aplícale un incremento del 21% de IVA.
select * from mantenimientos_flota;
rollback to antes_del_calculo;  -- Utilizando ROLLBACK y un SAVEPOINT, deshaz el cambio anterior y, sin cerrar la transacción, aplica el incremento del 10%.
UPDATE mantenimientos_flota SET coste_eur = CAST(TRIM(REPLACE(coste_reparacion, 'Euros', '')) AS DECIMAL(10,2)) * 1.10;
set sql_safe_updates = 1;
commit;

-- Ejercicio 2: Elimina los almacenes duplicados basándote en el campo cod_almacen. Debes conservar aquel cuya capacidad (capacidad_m3) sea la más alta. En caso de empate, conserva el registro con el id más bajo.

select * from almacenes;
select id,cod_almacen,capacidad_m3 from almacenes where capacidad_m3 not regexp '^[0-9]+$'; -- Vemos qué almacenes tienen letras o espacios en su capacidad
start transaction;
savepoint antes_tocar_nada;
set sql_safe_updates = 0;
update almacenes set capacidad_m3 = replace(capacidad_m3,'m3',''); -- Elimino m3, metros cúbicos y espacios 
update almacenes set capacidad_m3 = replace(capacidad_m3,'metros cúbicos','');
update almacenes set capacidad_m3 = trim(capacidad_m3); 
delete from almacenes where capacidad_m3 not regexp '^[0-9]+$'; -- Elimino lo sobrante

savepoint antes_de_eliminar;
SELECT a1.id AS id_a_borrar, a1.cod_almacen, a1.capacidad_m3 -- (VEO)Elimina los almacenes duplicados basándote en el campo cod_almacen. Debes conservar aquel cuya capacidad (capacidad_m3) sea la más alta. En caso de empate, conserva el registro con el id más bajo.
FROM almacenes a1
INNER JOIN almacenes a2 ON a1.cod_almacen = a2.cod_almacen
WHERE CAST(a1.capacidad_m3 AS UNSIGNED) < CAST(a2.capacidad_m3 AS UNSIGNED)
   OR (CAST(a1.capacidad_m3 AS UNSIGNED) = CAST(a2.capacidad_m3 AS UNSIGNED) AND a1.id > a2.id);

DELETE a1 FROM almacenes a1 -- ELIMINO LO ANTERIOR
INNER JOIN almacenes a2 ON a1.cod_almacen = a2.cod_almacen
WHERE CAST(a1.capacidad_m3 AS UNSIGNED) < CAST(a2.capacidad_m3 AS UNSIGNED)
   OR (CAST(a1.capacidad_m3 AS UNSIGNED) = CAST(a2.capacidad_m3 AS UNSIGNED) AND a1.id > a2.id);
   
SELECT cod_almacen, COUNT(*) AS total_repeticiones  -- Compruebo que no HAY NADA 
FROM almacenes 
GROUP BY cod_almacen 
HAVING COUNT(*) > 1;   

select id, cod_almacen, capacidad_m3 from almacenes where cod_almacen = 'ALM-001'; -- QUEDA ESTE Y LO ELIMINO
delete from almacenes where cod_almacen = 'ALM-001';
set sql_safe_updates = 1;   
commit;   


-- Ejercicio 3: Existen envíos con cliente_id que no figuran en la tabla de clientes. HUERFANOS

start transaction;
savepoint antes_del_3;
show tables;
select * from clientes;
select * from envios;
set sql_safe_updates = 0;

SELECT e.id AS id_envio, e.cliente_id AS cliente_huerfano -- ¿Cuántos envíos huérfanos = NULL tenemos realmente?
FROM envios e 
LEFT JOIN clientes c ON e.cliente_id = c.id 
WHERE c.id IS NULL;

UPDATE envios e  -- Reasignamos esos envíos al cliente genérico (id=1)
LEFT JOIN clientes c ON e.cliente_id = c.id 
SET e.cliente_id = 1 
WHERE c.id IS NULL;

set sql_safe_updates = 1;
commit;


ALTER TABLE envios  -- Creamos la Clave Foránea para proteger la integridad futura . Cada envio TIENE QUE TENER UN ID_CLIENTE OBLIGATORIAMENTE
ADD CONSTRAINT fk_envios_clientes 
FOREIGN KEY (cliente_id) REFERENCES clientes(id);


-- Ejercicio 4: Queremos detectar envíos con VELOCIDADES medias anómalas.Usaremos f_salida, f_entrega_real y ruta_distancia_km de la tabla envios.

select * from envios;
select f_salida, f_entrega_real, ruta_distancia_km from envios;

ALTER TABLE envios ADD COLUMN velocidad_media_kmh DECIMAL(10,2); --  Añadimos una columna para la velocidad media calculada
ALTER TABLE envios ADD COLUMN alerta_anomalia VARCHAR(50) DEFAULT 'NORMAL'; -- Añadimos una columna para marcar si es un dato anómalo o normal

start transaction;
savepoint inicio_4 ;
set sql_safe_updates = 0; 

update envios set ruta_distancia_km = replace(ruta_distancia_km,'km',''); -- Quitamos
update envios set ruta_distancia_km = trim(ruta_distancia_km);
UPDATE envios  -- CALCULAMOS VELOCIDAD MEDIA PARA TODOS LOS ENVIOS
SET velocidad_media_kmh = ruta_distancia_km / NULLIF(TIMESTAMPDIFF(HOUR, f_salida, f_entrega_real), 0) -- NULLIF(..., 0) convierte el 0 en NULL. Dividir por NULL da NULL (no da error).
WHERE f_salida IS NOT NULL AND f_entrega_real IS NOT NULL;



UPDATE envios SET alerta_anomalia = 'ANOMALÍA: Exceso Velocidad' WHERE velocidad_media_kmh > 90; -- Detectamos y marcamos las ANOMALIAS (Velocidades imposibles para camiones)
UPDATE envios SET alerta_anomalia = 'ANOMALÍA: Exceso Lentitud' WHERE velocidad_media_kmh < 20; -- Más de 90 km/h de media, o menos de 20 km/h de media

SELECT id, ruta_distancia_km, f_salida, f_entrega_real, velocidad_media_kmh, alerta_anomalia 
FROM envios 
WHERE alerta_anomalia LIKE 'ANOMALÍA%';
set sql_safe_updates = 1; 
rollback;
