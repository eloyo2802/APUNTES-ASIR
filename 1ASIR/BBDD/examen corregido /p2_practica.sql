-- Ejercicio 2 Saneamiento de Infraestructura --


SELECT 
    a1.cod_almacen,
    a2.cod_almacen,
    a1.ciudad_ubicacion,
    a2.ciudad_ubicacion,
    a1.id,
    a2.id
FROM
    almacenes AS a1
        JOIN
    almacenes AS a2 ON a1.cod_almacen = a2.cod_almacen;

    
start transaction;
set sql_safe_updates = 0;
savepoint antesdecambiarciudad;
UPDATE almacenes 
SET 
    ciudad_ubicacion = REPLACE(ciudad_ubicacion,
        'Barna',
        'Barcelona');
UPDATE almacenes 
SET 
    ciudad_ubicacion = REPLACE(ciudad_ubicacion,
        'VLC',
        'Valencia');
DELETE FROM almacenes 
WHERE
    ciudad_ubicacion IS NULL; 
rollback to antesdecambiarciudad;
DELETE a1 FROM almacenes AS a1
        JOIN
    almacenes AS a2 ON a1.cod_almacen = a2.cod_almacen 
WHERE
    CHAR_LENGTH(a1.ciudad_ubicacion) < CHAR_LENGTH(a2.ciudad_ubicacion)
    OR (CHAR_LENGTH(a1.ciudad_ubicacion) = CHAR_LENGTH(a2.ciudad_ubicacion)
    AND a2.id > a1.id);
    -- 2+5*2
ROLLBACK;
set sql_safe_updates = 1;

commit;

