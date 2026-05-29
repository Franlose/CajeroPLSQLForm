-- =============================================================
-- 4. CONSULTA DE VERIFICACIÓN DE INTEGRIDAD
-- =============================================================
SELECT u.nombre, m.tipo_operacion, m.total_importe, b.descripcion
FROM USUARIOS_CUENTAS u
JOIN MOVIMIENTOS m ON u.id_usuario = m.id_usuario
JOIN TIPOS_BILLETES b ON m.id_billete = b.id_billete;
