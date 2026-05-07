-- 2.2 Ejercicio 2: Saneamiento de Infraestructura (RA5 - 2 puntos)
select * from almacenes;
select id,cod_almacen,ciudad_ubicacion from almacenes where ciudad_ubicacion not regexp '^[0-9]+$'; -- Vemos qué almacenes tienen letras o espacios en su capacidad
start transaction;

set sql_safe_updates = 0;
update almacenes set cod_almacen = replace(ciudad_ubicacion,'Barna','Barcelona'); -- Elimino abreviaturas y mayusculas 
update almacenes set cod_almacen = replace(ciudad_ubicacion,'VLC','Valencia');
update almacenes set cod_almacen = trim(capacidad_m3); 
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

