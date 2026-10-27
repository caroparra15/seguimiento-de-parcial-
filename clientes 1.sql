-- =====================================================
-- Script 06: Examen #1 - Módulo de Clientes
-- Consultas, vista y procedimiento almacenado
-- Ejecutar DESPUÉS de los scripts 01 al 05 (y el 07 para datos de prueba)
-- =====================================================
USE eventos_premier;

-- -----------------------------------------------------
-- PREPARACIÓN: la tabla reservas necesita la columna
-- "observaciones" (la pide el procedimiento almacenado).
-- Si ya existe (porque ejecutaste el 01 actualizado), no hace nada.
-- -----------------------------------------------------
SET @existe = (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'eventos_premier'
      AND TABLE_NAME = 'reservas'
      AND COLUMN_NAME = 'observaciones'
);
SET @sql = IF(@existe = 0,
    'ALTER TABLE reservas ADD COLUMN observaciones VARCHAR(255) NULL AFTER estado',
    'SELECT ''La columna observaciones ya existe'' AS aviso');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =====================================================
-- CONSULTA 1: Clientes con más reservas, de mayor a menor
-- Propósito: identificar a los clientes más frecuentes.
-- Muestra nombre completo, número total de reservas y la
-- fecha de su última reserva (MAX). INNER JOIN deja solo
-- a los clientes que tienen al menos una reserva.
-- =====================================================
SELECT
    c.nombre_completo        AS cliente,
    COUNT(r.id)              AS total_reservas,
    MAX(r.fecha_inicio)      AS fecha_ultima_reserva
FROM clientes c
INNER JOIN reservas r ON r.cliente_id = c.id
GROUP BY c.id, c.nombre_completo
ORDER BY total_reservas DESC, c.nombre_completo ASC;

-- =====================================================
-- CONSULTA 2: Reservas programadas para los próximos 7 días
-- Propósito: planear la operación de la semana.
-- Usa BETWEEN entre el momento actual (NOW) y 7 días después.
-- Muestra cliente, salón, fecha del evento y estado.
-- =====================================================
SELECT
    c.nombre_completo  AS cliente,
    s.nombre           AS salon,
    r.fecha_inicio     AS fecha_evento,
    r.estado           AS estado_reserva
FROM reservas r
INNER JOIN clientes c ON c.id = r.cliente_id
INNER JOIN salones  s ON s.id = r.salon_id
WHERE r.fecha_inicio BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 7 DAY)
ORDER BY r.fecha_inicio ASC;

-- =====================================================
-- VISTA: vista_reservas_cliente
-- Propósito: resumen por cliente con su total de reservas
-- confirmadas y canceladas. Usa LEFT JOIN para incluir
-- también a los clientes sin reservas (aparecen con 0), y
-- COUNT(CASE ...) para contar solo las que cumplen el estado.
-- =====================================================
CREATE OR REPLACE VIEW vista_reservas_cliente AS
SELECT
    c.id                                                  AS cliente_id,
    c.nombre_completo                                     AS nombre_completo,
    COUNT(CASE WHEN r.estado = 'Confirmada' THEN 1 END)   AS total_reservas_confirmadas,
    COUNT(CASE WHEN r.estado = 'Cancelada'  THEN 1 END)   AS total_reservas_canceladas
FROM clientes c
LEFT JOIN reservas r ON r.cliente_id = c.id
GROUP BY c.id, c.nombre_completo;

SELECT * FROM vista_reservas_cliente;

-- =====================================================
-- CONSULTA 3: Clientes que aún no han realizado ninguna reserva
-- Propósito: encontrar clientes inactivos (para campañas o
-- seguimiento comercial), ordenados alfabéticamente.
-- LEFT JOIN + "r.id IS NULL" deja solo los clientes sin coincidencia.
-- =====================================================
SELECT
    c.id,
    c.nombre_completo,
    c.telefono,
    c.correo,
    c.tipo_cliente
FROM clientes c
LEFT JOIN reservas r ON r.cliente_id = c.id
WHERE r.id IS NULL
ORDER BY c.nombre_completo ASC;

-- =====================================================
-- PROCEDIMIENTO ALMACENADO: consultarHistorialCliente(id_cliente)
-- Propósito: mostrar todas las reservas de un cliente con
-- salón, fecha, estado y observaciones (si no hay, muestra
-- 'Sin observaciones'). Si el cliente no existe, lanza un error.
-- =====================================================
DROP PROCEDURE IF EXISTS consultarHistorialCliente;

DELIMITER $$

CREATE PROCEDURE consultarHistorialCliente(IN id_cliente INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM clientes WHERE id = id_cliente) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El cliente indicado no existe';
    END IF;

    SELECT
        r.id                                         AS reserva_id,
        s.nombre                                     AS salon,
        r.fecha_inicio                               AS fecha,
        r.estado                                     AS estado,
        COALESCE(r.observaciones, 'Sin observaciones') AS observaciones
    FROM reservas r
    INNER JOIN salones s ON s.id = r.salon_id
    WHERE r.cliente_id = id_cliente
    ORDER BY r.fecha_inicio DESC;
END$$

DELIMITER ;

-- Ejemplos de uso:
CALL consultarHistorialCliente(3);
CALL consultarHistorialCliente(1);

                                                   
