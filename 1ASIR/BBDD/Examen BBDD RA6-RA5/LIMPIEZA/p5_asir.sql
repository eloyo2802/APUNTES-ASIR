-- 2.5 Ejercicio 5: Normalización de Gestión (RA5 - 2 puntos)

start transaction;
UPDATE envios e INNER JOIN ciudades c ON c.nombre = UPPER(TRIM(e.ruta_origen_ciudad))
SET e.ciudad_orige_id = c.id;




