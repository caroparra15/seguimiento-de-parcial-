-- =====================================================
-- Script 07: Datos adicionales para probar el Examen #1
-- Ejecutar UNA SOLA VEZ, después del script 06.
-- Las fechas se calculan a partir de HOY, así siempre
-- caen dentro de los próximos 7 días.
-- =====================================================
USE eventos_premier;

-- Clientes sin ninguna reserva
INSERT INTO clientes (nombre_completo, identificacion, telefono, correo, tipo_cliente) VALUES
('Pedro Martínez', '1002003004', '3045556677', 'pedro.martinez@correo.com', 'Individual'),
('Ana Beltrán',    '1005006007', '3118889900', 'ana.beltran@correo.com',    'Individual');

-- Reservas dentro de los próximos 7 días
INSERT INTO reservas (cliente_id, salon_id, fecha_inicio, fecha_fin, estado, observaciones) VALUES
(2, 2, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 2 DAY), '15:00:00'),
       TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 2 DAY), '17:00:00'), 'Confirmada', 'Requiere equipo de sonido'),
(1, 3, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 5 DAY), '16:00:00'),
       TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 5 DAY), '18:00:00'), 'Pendiente', NULL);

-- Reservas canceladas (no bloquean el salón ni lo cambian a Ocupado)
INSERT INTO reservas (cliente_id, salon_id, fecha_inicio, fecha_fin, estado, observaciones) VALUES
(1, 2, '2026-11-20 10:00:00', '2026-11-20 12:00:00', 'Cancelada', 'Cancelada por el cliente'),
(4, 1, '2026-12-05 09:00:00', '2026-12-05 11:00:00', 'Cancelada', NULL);

-- Observaciones de ejemplo en reservas existentes
UPDATE reservas SET observaciones = 'Evento corporativo de fin de año' WHERE id = 4;
UPDATE reservas SET observaciones = 'Cumpleaños con decoración incluida' WHERE id = 1;

