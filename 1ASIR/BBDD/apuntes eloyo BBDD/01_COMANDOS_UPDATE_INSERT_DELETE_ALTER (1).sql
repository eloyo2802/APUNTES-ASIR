-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║   COMANDOS DENTRO DE UPDATE / INSERT / DELETE / ALTER TABLE               ║
-- ║   logistica_global | ASIR 1º 2025/2026                                    ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

USE logistica_global;

-- ==============================================================================
-- ██  BLOQUE 1 — DENTRO DE UPDATE
-- ==============================================================================

-- ──────────────────────────────────────────────────────────────────────────────
-- U1. SET col = valor_fijo
-- Qué hace: asigna un valor constante a la columna
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE clientes SET razon_social = 'Cliente Genérico' WHERE id = 1;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U2. SET col = otra_columna  (copiar valor de otra columna)
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE empleados SET activo = activo_boolean;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U3. SET col = TRIM(col)  — eliminar espacios en la misma columna
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE almacenes
SET nombre_sucursal = TRIM(nombre_sucursal)
WHERE nombre_sucursal != TRIM(nombre_sucursal);
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U4. SET col = UPPER(TRIM(col))  — mayúsculas + quitar espacios
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE almacenes
SET ciudad_ubicacion = UPPER(TRIM(ciudad_ubicacion))
WHERE ciudad_ubicacion IS NOT NULL;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U5. SET col = LOWER(col)  — convertir a minúsculas
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE empleados
SET email_corp = LOWER(TRIM(email_corp))
WHERE email_corp IS NOT NULL;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U6. SET col = REPLACE(col, 'buscar', 'reemplazar')
-- Qué hace: sustituye todas las ocurrencias de un texto por otro
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE empleados
SET email_corp = REPLACE(email_corp, '@@', '@')
WHERE email_corp LIKE '%@@%';
COMMIT;

-- Otro ejemplo: quitar texto sobrante
START TRANSACTION;
UPDATE almacenes
SET ciudad_ubicacion = REPLACE(ciudad_ubicacion, ' (provisional)', '')
WHERE ciudad_ubicacion LIKE '% (provisional)';
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U7. SET col = CONCAT(col, ' texto')  — añadir texto a una columna
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE envios
SET tracking_number = CONCAT('TRK-GENERADO-', id)
WHERE tracking_number IS NULL;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U8. SET col = CAST(TRIM(SUBSTRING_INDEX(col_texto, ' ', 1)) AS DECIMAL(10,2))
-- Qué hace: extrae el número de un texto como '450 Euros' y lo convierte
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE mantenimientos_flota
SET coste_eur = CAST(TRIM(SUBSTRING_INDEX(coste_reparacion, ' ', 1)) AS DECIMAL(10,2));
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U9. SET col = ROUND(expresion, decimales)  — redondear resultado
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE mantenimientos_flota
SET coste_eur = ROUND(
    CAST(TRIM(SUBSTRING_INDEX(coste_reparacion, ' ', 1)) AS DECIMAL(10,2)) * 1.10,
    2
);
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U10. SET col = col * 1.21  — multiplicar (aplicar IVA, descuento, etc.)
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE mantenimientos_flota SET coste_eur = ROUND(coste_eur * 1.21, 2);
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U11. SET col = col + valor  /  col = col - valor  (sumar/restar)
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE envios SET dias_retraso = dias_retraso + 1 WHERE tiene_retraso = 1;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U12. SET col = IF(condicion, valor_true, valor_false)
-- Qué hace: asigna un valor u otro según una condición dentro del SET
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE envios
SET velocidad_anomala = IF(velocidad_media_kmh > 120 OR velocidad_media_kmh <= 0, 1, 0);
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U13. SET col = CASE WHEN ... THEN ... ELSE ... END
-- Qué hace: condicional múltiple dentro del SET, más potente que IF
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE empleados
SET puesto_rol = CASE
    WHEN salario_decimal > 2500 THEN 'Senior'
    WHEN salario_decimal > 1500 THEN 'Junior'
    ELSE 'Becario'
END
WHERE salario_decimal IS NOT NULL;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U14. SET col = NULL  — poner un campo a nulo explícitamente
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE incidencias SET envio_id = NULL WHERE envio_id = 888888;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U15. SET col = CURDATE()  /  SET col = NOW()
-- Qué hace: asigna la fecha/hora actual del servidor
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE envios SET f_entrega_real = CURDATE() WHERE estado_envio = 'ENTREGADO' AND f_entrega_real IS NULL;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U16. SET col = STR_TO_DATE(col_texto, '%d/%m/%Y')
-- Qué hace: convierte columna de texto a fecha real dentro de un UPDATE
-- ──────────────────────────────────────────────────────────────────────────────
-- (requiere columna de tipo DATE)
-- ALTER TABLE envios ADD COLUMN f_salida_date DATE;
START TRANSACTION;
UPDATE envios
SET f_salida_date = COALESCE(
    STR_TO_DATE(f_salida, '%d/%m/%Y'),
    STR_TO_DATE(f_salida, '%d-%m-%Y'),
    STR_TO_DATE(f_salida, '%Y-%m-%d'),
    STR_TO_DATE(f_salida, '%Y/%m/%d')
)
WHERE f_salida IS NOT NULL;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U17. SET col = TIMESTAMPDIFF(HOUR, col1, col2)
-- Qué hace: guarda la diferencia en horas entre dos columnas en una nueva columna
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE envios
SET horas_trayecto = TIMESTAMPDIFF(HOUR, f_salida, f_entrega_real)
WHERE f_salida REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}';
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U18. SET col = DATEDIFF(col1, col2)
-- Qué hace: guarda la diferencia en días entre dos fechas
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE envios
SET dias_retraso = DATEDIFF(
    COALESCE(STR_TO_DATE(f_entrega_real,   '%d/%m/%Y'), STR_TO_DATE(f_entrega_real,   '%Y-%m-%d')),
    COALESCE(STR_TO_DATE(f_llegada_prevista,'%d/%m/%Y'), STR_TO_DATE(f_llegada_prevista,'%Y-%m-%d'))
)
WHERE f_entrega_real IS NOT NULL AND f_llegada_prevista IS NOT NULL;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U19. UPDATE con JOIN  — actualizar usando datos de otra tabla
-- Qué hace: vincula dos tablas y actualiza una columna con el valor de la otra
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE envios e
INNER JOIN ciudades c ON c.nombre = UPPER(TRIM(e.ruta_origen_ciudad))
SET e.ciudad_origen_id = c.id;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U20. UPDATE con LEFT JOIN + WHERE IS NULL  — corregir huérfanos
-- Qué hace: actualiza solo las filas cuya FK no tiene correspondencia en el padre
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE envios e
LEFT JOIN clientes c ON e.cliente_id = c.id
SET e.cliente_id = 1
WHERE c.id IS NULL;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U21. UPDATE con subconsulta en WHERE
-- Qué hace: filtra qué filas actualizar usando el resultado de otra SELECT
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE empleados
SET almacen_id = NULL
WHERE almacen_id NOT IN (SELECT id FROM almacenes);
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U22. UPDATE con NULLIF  — evitar divisiones por cero
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE envios
SET velocidad_media_kmh = ROUND(
    CAST(TRIM(SUBSTRING_INDEX(ruta_distancia_km, ' ', 1)) AS DECIMAL(10,2))
    / NULLIF(TIMESTAMPDIFF(HOUR, f_salida, f_entrega_real), 0),
    2
)
WHERE f_salida REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}';
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U23. Actualizar VARIAS columnas en un mismo UPDATE
-- Qué hace: modifica múltiples columnas en una sola sentencia (más eficiente)
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE envios
SET
    velocidad_media_kmh = ROUND(
        CAST(TRIM(SUBSTRING_INDEX(ruta_distancia_km,' ',1)) AS DECIMAL(10,2))
        / NULLIF(TIMESTAMPDIFF(HOUR, f_salida, f_entrega_real), 0), 2),
    velocidad_anomala = IF(
        CAST(TRIM(SUBSTRING_INDEX(ruta_distancia_km,' ',1)) AS DECIMAL(10,2))
        / NULLIF(TIMESTAMPDIFF(HOUR, f_salida, f_entrega_real), 0) > 120, 1, 0),
    tiene_retraso = IF(DATEDIFF(f_entrega_real, f_llegada_prevista) > 0, 1, 0)
WHERE f_salida REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}';
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U24. WHERE col REGEXP 'patron'  — filtrar qué filas actualizar con regex
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE envios
SET distancia_num = CAST(TRIM(SUBSTRING_INDEX(ruta_distancia_km,' ',1)) AS DECIMAL(10,2))
WHERE ruta_distancia_km REGEXP '^[0-9]';
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- U25. WHERE col IS NULL  /  WHERE col IS NOT NULL
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
UPDATE vehiculos
SET matricula = CONCAT('SIN-MAT-', id)
WHERE matricula IS NULL OR TRIM(matricula) = '';
COMMIT;


-- ==============================================================================
-- ██  BLOQUE 2 — DENTRO DE INSERT
-- ==============================================================================

-- ──────────────────────────────────────────────────────────────────────────────
-- I1. INSERT INTO ... VALUES (fila única)
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
INSERT INTO ciudades (nombre) VALUES ('MADRID');
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- I2. INSERT INTO ... VALUES (varias filas a la vez)
-- Qué hace: inserta múltiples filas en una sola sentencia (más eficiente)
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
INSERT INTO ciudades (nombre) VALUES
    ('MADRID'),
    ('BARCELONA'),
    ('VALENCIA'),
    ('SEVILLA'),
    ('BILBAO');
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- I3. INSERT INTO ... SELECT  — insertar desde otra tabla
-- Qué hace: puebla una tabla nueva con el resultado de una SELECT
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
INSERT INTO ciudades (nombre)
SELECT DISTINCT UPPER(TRIM(ruta_origen_ciudad))
FROM envios
WHERE ruta_origen_ciudad IS NOT NULL
ORDER BY 1;
COMMIT;

-- Combinando dos columnas con UNION:
START TRANSACTION;
INSERT INTO ciudades (nombre)
SELECT DISTINCT UPPER(TRIM(ciudad))
FROM (
    SELECT ruta_origen_ciudad  AS ciudad FROM envios WHERE ruta_origen_ciudad  IS NOT NULL
    UNION
    SELECT ruta_destino_ciudad AS ciudad FROM envios WHERE ruta_destino_ciudad IS NOT NULL
) t
ORDER BY ciudad;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- I4. INSERT IGNORE  — ignora filas que violan clave única
-- Qué hace: si ya existe la ciudad, no falla, simplemente la omite
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
INSERT IGNORE INTO ciudades (nombre)
SELECT DISTINCT UPPER(TRIM(ruta_destino_ciudad))
FROM envios
WHERE ruta_destino_ciudad IS NOT NULL;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- I5. INSERT INTO ... SELECT con funciones en el SELECT
-- Qué hace: transforma datos mientras los inserta
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
INSERT INTO penalizaciones (envio_id, importe_pen, motivo, f_penalizacion)
SELECT
    id,
    dias_retraso * 5.00,
    CONCAT('Retraso de ', dias_retraso, ' días'),
    CURDATE()
FROM envios
WHERE tiene_retraso = 1 AND dias_retraso > 0;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- I6. INSERT INTO ... SELECT con CASE dentro del SELECT
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
INSERT INTO resumen_empleados (empleado_id, categoria, f_registro)
SELECT
    id,
    CASE
        WHEN salario_decimal > 2500 THEN 'Senior'
        WHEN salario_decimal > 1500 THEN 'Junior'
        ELSE 'Becario'
    END,
    CURDATE()
FROM empleados
WHERE salario_decimal IS NOT NULL;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- I7. INSERT INTO ... ON DUPLICATE KEY UPDATE
-- Qué hace: si ya existe (clave única repetida) en vez de fallar, actualiza
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
INSERT INTO ciudades (nombre) VALUES ('MADRID')
ON DUPLICATE KEY UPDATE nombre = UPPER(TRIM('Madrid'));
COMMIT;


-- ==============================================================================
-- ██  BLOQUE 3 — DENTRO DE DELETE
-- ==============================================================================

-- ──────────────────────────────────────────────────────────────────────────────
-- D1. DELETE WHERE col = valor
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
DELETE FROM almacenes WHERE ciudad_ubicacion = 'Narnia';
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- D2. DELETE WHERE col IS NULL
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
DELETE FROM empleados WHERE nif_nie IS NULL;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- D3. DELETE WHERE col NOT REGEXP  — borrar filas con formato inválido
-- Qué hace: elimina registros cuyo campo no cumple el patrón esperado
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
DELETE FROM almacenes
WHERE capacidad_m3 NOT REGEXP '^[0-9]' OR capacidad_m3 IS NULL;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- D4. DELETE WHERE TRIM(col) = ''  — borrar registros vacíos/solo espacios
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
DELETE FROM clientes WHERE TRIM(cif_nif) = '' OR cif_nif IS NULL;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- D5. DELETE con SELF JOIN  — borrar duplicados conservando el mejor
-- Qué hace: compara la tabla consigo misma y borra las filas peores
-- PATRÓN MÁS IMPORTANTE DEL EXAMEN para duplicados
-- ──────────────────────────────────────────────────────────────────────────────

-- Opción A: conservar el id más bajo (más simple)
START TRANSACTION;
DELETE a1 FROM almacenes a1
INNER JOIN almacenes a2
    ON  a1.cod_almacen = a2.cod_almacen
    AND a1.id > a2.id;   -- borra el que tiene id mayor (conserva el menor)
COMMIT;

-- Opción B: conservar el de mayor capacidad, en empate el id más bajo
START TRANSACTION;
DELETE a1 FROM almacenes a1
INNER JOIN almacenes a2
    ON a1.cod_almacen = a2.cod_almacen
    AND (
        CAST(TRIM(SUBSTRING_INDEX(a1.capacidad_m3,' ',1)) AS DECIMAL(10,2)) <
        CAST(TRIM(SUBSTRING_INDEX(a2.capacidad_m3,' ',1)) AS DECIMAL(10,2))
        OR (
            CAST(TRIM(SUBSTRING_INDEX(a1.capacidad_m3,' ',1)) AS DECIMAL(10,2)) =
            CAST(TRIM(SUBSTRING_INDEX(a2.capacidad_m3,' ',1)) AS DECIMAL(10,2))
            AND a1.id > a2.id
        )
    );
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- D6. DELETE con JOIN a otra tabla  — borrar según condición en tabla relacionada
-- Qué hace: borra incidencias cuyos envíos ya no existen
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
DELETE i FROM incidencias i
LEFT JOIN envios e ON i.envio_id = e.id
WHERE e.id IS NULL;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- D7. DELETE con subconsulta en WHERE  — borrar según otra SELECT
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
DELETE FROM empleados
WHERE almacen_id NOT IN (SELECT id FROM almacenes)
  AND almacen_id IS NOT NULL;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- D8. DELETE con LIMIT  — borrar solo N filas (útil si hay muchísimos registros)
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
DELETE FROM envios WHERE estado_envio = 'CANCELADO' LIMIT 100;
COMMIT;

-- ──────────────────────────────────────────────────────────────────────────────
-- D9. DELETE con ORDER BY + LIMIT  — borrar los N más antiguos/peores
-- ──────────────────────────────────────────────────────────────────────────────
START TRANSACTION;
DELETE FROM mantenimientos_flota
ORDER BY id ASC
LIMIT 10;
COMMIT;


-- ==============================================================================
-- ██  BLOQUE 4 — DENTRO DE ALTER TABLE
-- ==============================================================================

-- ──────────────────────────────────────────────────────────────────────────────
-- A1. ADD COLUMN tipo_dato  — añadir columna simple
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE mantenimientos_flota ADD COLUMN coste_eur      DECIMAL(10,2);
ALTER TABLE empleados            ADD COLUMN salario_decimal DECIMAL(10,2);
ALTER TABLE envios               ADD COLUMN importe_eur     DECIMAL(10,2);
ALTER TABLE envios               ADD COLUMN distancia_num   DECIMAL(10,2);

-- ──────────────────────────────────────────────────────────────────────────────
-- A2. ADD COLUMN con DEFAULT  — columna con valor por defecto
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE envios ADD COLUMN velocidad_anomala TINYINT(1)   DEFAULT 0;
ALTER TABLE envios ADD COLUMN tiene_retraso     TINYINT(1)   DEFAULT 0;
ALTER TABLE envios ADD COLUMN dias_retraso      INT          DEFAULT 0;

-- ──────────────────────────────────────────────────────────────────────────────
-- A3. ADD COLUMN NOT NULL  — columna obligatoria (requiere DEFAULT o datos existentes)
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE ciudades ADD COLUMN pais VARCHAR(100) NOT NULL DEFAULT 'España';

-- ──────────────────────────────────────────────────────────────────────────────
-- A4. ADD COLUMN AFTER col  — insertar la columna en posición concreta
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE almacenes  ADD COLUMN capacidad_num  DECIMAL(10,2) AFTER capacidad_m3;
ALTER TABLE empleados  ADD COLUMN salario_decimal DECIMAL(10,2) AFTER salario_base_sucio;

-- ──────────────────────────────────────────────────────────────────────────────
-- A5. ADD COLUMN FIRST  — insertar como primera columna
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE almacenes ADD COLUMN codigo_interno INT FIRST;

-- ──────────────────────────────────────────────────────────────────────────────
-- A6. ADD varias columnas a la vez
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE envios
    ADD COLUMN ciudad_origen_id  INT,
    ADD COLUMN ciudad_destino_id INT,
    ADD COLUMN velocidad_media_kmh DECIMAL(10,2),
    ADD COLUMN velocidad_anomala   TINYINT(1) DEFAULT 0;

-- ──────────────────────────────────────────────────────────────────────────────
-- A7. DROP COLUMN  — eliminar columna
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE empleados DROP COLUMN prueba;
ALTER TABLE envios    DROP COLUMN columna_vieja;

-- ──────────────────────────────────────────────────────────────────────────────
-- A8. MODIFY COLUMN  — cambiar tipo de dato de una columna existente
-- Qué hace: cambia el tipo, tamaño o restricciones sin perder la columna
-- CUIDADO: puede truncar datos si el nuevo tipo es más pequeño
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE empleados MODIFY COLUMN nif_nie     VARCHAR(50)    NOT NULL;
ALTER TABLE clientes  MODIFY COLUMN cif_nif     VARCHAR(50)    NOT NULL;
ALTER TABLE envios    MODIFY COLUMN estado_envio VARCHAR(50)    NOT NULL DEFAULT 'PENDIENTE';
ALTER TABLE almacenes MODIFY COLUMN capacidad_m3 VARCHAR(100);   -- ampliar tamaño

-- ──────────────────────────────────────────────────────────────────────────────
-- A9. MODIFY COLUMN para añadir NOT NULL a columna existente
-- (primero limpiar NULLs con UPDATE, luego aplicar esto)
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE empleados MODIFY COLUMN nif_nie VARCHAR(50) NOT NULL;
ALTER TABLE vehiculos MODIFY COLUMN matricula VARCHAR(50) NOT NULL;

-- ──────────────────────────────────────────────────────────────────────────────
-- A10. MODIFY COLUMN para quitar NOT NULL (permitir NULLs)
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE envios MODIFY COLUMN almacen_destino_id INT NULL;

-- ──────────────────────────────────────────────────────────────────────────────
-- A11. RENAME COLUMN nombre_viejo TO nombre_nuevo
-- Qué hace: cambia el nombre de la columna sin perder datos ni tipo
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE empleados RENAME COLUMN activo_boolean TO activo_raw;
ALTER TABLE envios    RENAME COLUMN ruta_distancia_km TO distancia_km_texto;

-- ──────────────────────────────────────────────────────────────────────────────
-- A12. ADD PRIMARY KEY
-- Qué hace: define la clave primaria (solo si la tabla no la tiene ya)
-- ──────────────────────────────────────────────────────────────────────────────
-- ALTER TABLE tabla_sin_pk ADD PRIMARY KEY (id);
-- Con AUTO_INCREMENT:
-- ALTER TABLE tabla_sin_pk MODIFY COLUMN id INT AUTO_INCREMENT, ADD PRIMARY KEY (id);

-- ──────────────────────────────────────────────────────────────────────────────
-- A13. DROP PRIMARY KEY  — eliminar clave primaria
-- ──────────────────────────────────────────────────────────────────────────────
-- ALTER TABLE tabla DROP PRIMARY KEY;
-- (Si el campo es AUTO_INCREMENT, primero hacer MODIFY para quitárselo)

-- ──────────────────────────────────────────────────────────────────────────────
-- A14. ADD CONSTRAINT ... FOREIGN KEY REFERENCES
-- Qué hace: protege integridad referencial. Rechaza valores que no existan en padre.
-- OPCIONES ON DELETE / ON UPDATE:
--   CASCADE     → propaga el cambio/borrado al hijo automáticamente
--   SET NULL    → pone NULL en el hijo si se borra/cambia el padre
--   RESTRICT    → impide borrar/cambiar el padre si tiene hijos (por defecto)
--   NO ACTION   → igual que RESTRICT en MySQL
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE envios
    ADD CONSTRAINT fk_envios_cliente
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
    ON UPDATE CASCADE
    ON DELETE SET NULL;

ALTER TABLE envios
    ADD CONSTRAINT fk_envios_vehiculo
    FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(id)
    ON UPDATE CASCADE
    ON DELETE SET NULL;

ALTER TABLE envios
    ADD CONSTRAINT fk_envios_ciudad_origen
    FOREIGN KEY (ciudad_origen_id) REFERENCES ciudades(id)
    ON UPDATE CASCADE
    ON DELETE SET NULL;

ALTER TABLE empleados
    ADD CONSTRAINT fk_empleados_almacen
    FOREIGN KEY (almacen_id) REFERENCES almacenes(id)
    ON UPDATE CASCADE
    ON DELETE SET NULL;

ALTER TABLE incidencias
    ADD CONSTRAINT fk_incidencias_envio
    FOREIGN KEY (envio_id) REFERENCES envios(id)
    ON UPDATE CASCADE
    ON DELETE SET NULL;

ALTER TABLE mantenimientos_flota
    ADD CONSTRAINT fk_mantenimientos_vehiculo
    FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE;

-- ──────────────────────────────────────────────────────────────────────────────
-- A15. DROP FOREIGN KEY  — eliminar FK por nombre
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE envios DROP FOREIGN KEY fk_envios_cliente;
ALTER TABLE envios DROP FOREIGN KEY fk_envios_vehiculo;

-- ──────────────────────────────────────────────────────────────────────────────
-- A16. ADD CONSTRAINT ... UNIQUE  — restricción de unicidad
-- Qué hace: impide que dos filas tengan el mismo valor en esa columna
-- (limpiar duplicados con DELETE antes de aplicarlo)
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE clientes  ADD CONSTRAINT uq_clientes_cif  UNIQUE (cif_nif);
ALTER TABLE almacenes ADD CONSTRAINT uq_almacen_cod   UNIQUE (cod_almacen);
ALTER TABLE empleados ADD CONSTRAINT uq_empleado_nif  UNIQUE (nif_nie);
ALTER TABLE vehiculos ADD CONSTRAINT uq_vehiculo_mat  UNIQUE (matricula);
ALTER TABLE ciudades  ADD CONSTRAINT uq_ciudades_nom  UNIQUE (nombre);

-- UNIQUE sobre varias columnas combinadas:
ALTER TABLE envios ADD CONSTRAINT uq_envio_tracking UNIQUE (tracking_number);

-- ──────────────────────────────────────────────────────────────────────────────
-- A17. DROP INDEX  — eliminar índice/unique
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE clientes DROP INDEX uq_clientes_cif;
ALTER TABLE almacenes DROP INDEX uq_almacen_cod;

-- ──────────────────────────────────────────────────────────────────────────────
-- A18. ADD INDEX  — índice de rendimiento (no es restricción, solo velocidad)
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE envios    ADD INDEX idx_envios_estado   (estado_envio);
ALTER TABLE envios    ADD INDEX idx_envios_cliente  (cliente_id);
ALTER TABLE empleados ADD INDEX idx_empleados_email (email_corp);

-- Índice compuesto (sobre varias columnas):
ALTER TABLE envios ADD INDEX idx_envios_ruta (ruta_origen_ciudad, ruta_destino_ciudad);

-- ──────────────────────────────────────────────────────────────────────────────
-- A19. ADD CHECK  — restricción de validación de valor (MySQL 8.0+)
-- Qué hace: rechaza inserciones/actualizaciones que no cumplan la condición
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE mantenimientos_flota
    ADD CONSTRAINT chk_coste_positivo CHECK (coste_eur >= 0);

ALTER TABLE envios
    ADD CONSTRAINT chk_velocidad CHECK (velocidad_media_kmh IS NULL OR velocidad_media_kmh >= 0);

ALTER TABLE empleados
    ADD CONSTRAINT chk_salario CHECK (salario_decimal IS NULL OR salario_decimal >= 0);

-- ──────────────────────────────────────────────────────────────────────────────
-- A20. DROP CHECK  — eliminar restricción CHECK
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE mantenimientos_flota DROP CHECK chk_coste_positivo;

-- ──────────────────────────────────────────────────────────────────────────────
-- A21. RENAME TABLE  — renombrar la tabla entera
-- ──────────────────────────────────────────────────────────────────────────────
-- ALTER TABLE empleados RENAME TO staff;
-- RENAME TABLE empleados TO staff, almacenes TO warehouses;  -- varias a la vez

-- ──────────────────────────────────────────────────────────────────────────────
-- A22. ENGINE  — cambiar motor de almacenamiento
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE almacenes ENGINE = InnoDB;   -- InnoDB soporta FK y transacciones
-- ALTER TABLE tabla ENGINE = MyISAM;    -- MyISAM NO soporta FK

-- ──────────────────────────────────────────────────────────────────────────────
-- A23. CHARACTER SET / COLLATE  — cambiar juego de caracteres
-- Qué hace: cambia la codificación de la tabla (importante para tildes y ñ)
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE clientes
    CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Solo una columna:
ALTER TABLE empleados
    MODIFY COLUMN nombre_completo VARCHAR(200)
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ──────────────────────────────────────────────────────────────────────────────
-- A24. AUTO_INCREMENT  — resetear o cambiar el valor del contador
-- Qué hace: fija el próximo valor que se asignará en AUTO_INCREMENT
-- ──────────────────────────────────────────────────────────────────────────────
ALTER TABLE ciudades AUTO_INCREMENT = 1;    -- reiniciar a 1
ALTER TABLE ciudades AUTO_INCREMENT = 100;  -- el próximo id será 100

-- ==============================================================================
-- ██  RESUMEN RÁPIDO  — ¿qué va dentro de cada uno?
-- ==============================================================================
/*
UPDATE SET →  TRIM, UPPER, LOWER, REPLACE, CONCAT, CAST, ROUND,
              SUBSTRING_INDEX, IF, CASE, NULL, CURDATE, NOW,
              STR_TO_DATE, TIMESTAMPDIFF, DATEDIFF, NULLIF,
              col * num, col + num, col - num
              + JOIN / LEFT JOIN / subconsulta en WHERE

INSERT →      VALUES fila única / VALUES múltiples,
              INSERT IGNORE, INSERT ... SELECT,
              ON DUPLICATE KEY UPDATE,
              funciones en el SELECT (UPPER, TRIM, CONCAT, CASE, CURDATE...)

DELETE →      WHERE col = / IS NULL / NOT REGEXP / TRIM = '',
              SELF JOIN (duplicados),
              JOIN a otra tabla (huérfanos),
              subconsulta en WHERE,
              LIMIT, ORDER BY + LIMIT

ALTER TABLE → ADD COLUMN (+ tipo + DEFAULT + NOT NULL + AFTER + FIRST)
              DROP COLUMN
              MODIFY COLUMN (cambiar tipo, NOT NULL, DEFAULT)
              RENAME COLUMN
              ADD/DROP PRIMARY KEY
              ADD/DROP FOREIGN KEY (REFERENCES + ON DELETE/UPDATE)
              ADD/DROP UNIQUE
              ADD/DROP INDEX
              ADD/DROP CHECK
              RENAME TABLE
              ENGINE = InnoDB
              AUTO_INCREMENT = N
              CONVERT TO CHARACTER SET
*/
-- ==============================================================================
