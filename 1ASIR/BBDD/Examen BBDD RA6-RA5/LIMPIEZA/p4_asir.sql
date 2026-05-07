-- 2.4 Ejercicio 4: Análisis de Tránsito (RA5 - 2 puntos)
select * from envios;
select f_salida, f_entrega_real, ruta_distancia_km from envios;

ALTER TABLE envios ADD COLUMN horas_transito DECIMAL(10,2); --  Añadimos una columna para las horas_transito

start transaction;
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