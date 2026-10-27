# Sistema de Reservas de Salones de Eventos — Eventos Premier S.A.S.

## Descripción del proyecto
Base de datos en **MySQL** para digitalizar la gestión de reservas de una empresa de alquiler de salones para reuniones, fiestas y conferencias. Permite controlar salones, clientes, reservas y pagos, garantizar la disponibilidad y generar reportes de uso e ingresos.

Incluye:
- **Tablas relacionadas** con llaves foráneas: `encargados`, `salones`, `clientes`, `reservas`, `pagos`, `auditoria_precios`.
- **Funciones**: `calcular_total_reserva` (con IVA 19%) y `verificar_disponibilidad`.
- **Triggers**: cambio de estado del salón al reservar/eliminar, auditoría de precios y validación/cálculo automático de la reserva.
- **Vista** `vista_resumen_reservas` y consultas de reportes.

## Estructura del repositorio
```
eventos-premier/
├── 01_crear_base_datos.sql      # CREATE DATABASE y CREATE TABLE
├── 02_funciones.sql             # CREATE FUNCTION
├── 03_triggers.sql              # CREATE TRIGGER
├── 04_datos_prueba.sql          # INSERT de ejemplo
├── 05_vistas_y_consultas.sql    # CREATE VIEW, SELECT y pruebas
├── 06_examen_clientes.sql       # Examen #1: consultas, vista y procedimiento de clientes
├── 07_datos_examen.sql          # Datos adicionales para probar el examen
└── README.md
```

## Requisitos
MySQL **8.0.16 o superior** (por las restricciones `CHECK`). MySQL Workbench, DBeaver o la consola.

## Instrucciones de ejecución
Ejecuta los scripts **en este orden**:

```bash
mysql -u root -p < 01_crear_base_datos.sql
mysql -u root -p < 02_funciones.sql
mysql -u root -p < 03_triggers.sql
mysql -u root -p < 04_datos_prueba.sql
mysql -u root -p < 05_vistas_y_consultas.sql
mysql -u root -p < 06_examen_clientes.sql
mysql -u root -p < 07_datos_examen.sql
```

En MySQL Workbench: abre cada archivo (File > Open SQL Script) y ejecútalo con el rayo ⚡ en el mismo orden.

## Reglas de negocio
- `total_horas` y `valor_total` se calculan solos al insertar la reserva (`valor_total = precio_hora × horas × 1.19`).
- No se permite reservar un salón en mantenimiento ni con horario cruzado (error `45000`). Las reservas canceladas no bloquean el horario.
- Al registrar una reserva el salón pasa a **Ocupado**; al eliminarla vuelve a **Disponible** (solo si ya no tiene otras reservas activas).
- Cada cambio de `precio_hora` queda registrado en `auditoria_precios` con usuario, fecha y valor anterior/nuevo.

## Ejemplos

### Funciones
```sql
SELECT calcular_total_reserva(80000, 4);   -- 380800.00
SELECT verificar_disponibilidad(1, '2026-11-05 19:00:00', '2026-11-05 21:00:00');  -- 0 (ocupado)
SELECT verificar_disponibilidad(1, '2026-11-06 10:00:00', '2026-11-06 12:00:00');  -- 1 (disponible)
```

### Triggers
```sql
-- Auditoría de precios
UPDATE salones SET precio_hora = 90000 WHERE id = 1;
SELECT * FROM auditoria_precios;

-- Reserva -> el salón queda "Ocupado"
INSERT INTO reservas (cliente_id, salon_id, fecha_inicio, fecha_fin)
VALUES (1, 3, '2026-12-10 10:00:00', '2026-12-10 12:00:00');

-- Eliminar reserva -> el salón vuelve a "Disponible"
DELETE FROM reservas WHERE id = 8;
```

### Consultas
```sql
-- Reservas en un rango de fechas
SELECT * FROM vista_resumen_reservas
WHERE fecha_inicio BETWEEN '2026-11-01' AND '2026-11-30 23:59:59';

-- Salones disponibles con capacidad mayor a 40
SELECT * FROM salones WHERE capacidad > 40 AND estado = 'Disponible';

-- Clientes corporativos con más de 3 reservas
SELECT c.nombre_completo, COUNT(r.id) AS total_reservas
FROM clientes c JOIN reservas r ON r.cliente_id = c.id
WHERE c.tipo_cliente = 'Corporativo'
GROUP BY c.id, c.nombre_completo
HAVING COUNT(r.id) > 3;
```

## Subir a GitHub
```bash
git init
git add .
git commit -m "Sistema de reservas de salones - Eventos Premier"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/eventos-premier.git
git push -u origin main
```

## Créditos y autor
Proyecto académico desarrollado por **Carolina** — Técnico en Programación de Software e Inteligencia Artificial, CampusLand (San Gil, Santander, Colombia).