-- =============================================================
-- 3. CARGA DE DATOS MAESTROS Y EJEMPLOS (DML)
-- =============================================================

-- Catálogo de Billetes estándar
INSERT INTO TIPOS_BILLETES VALUES (5,  'Billete de 5 Euros');
INSERT INTO TIPOS_BILLETES VALUES (10, 'Billete de 10 Euros');
INSERT INTO TIPOS_BILLETES VALUES (20, 'Billete de 20 Euros');
INSERT INTO TIPOS_BILLETES VALUES (50, 'Billete de 50 Euros');

-- Usuarios de prueba
INSERT INTO USUARIOS_CUENTAS VALUES ('admin01', '1234', 'Administrador del Sistema', 0, 'S');
INSERT INTO USUARIOS_CUENTAS VALUES ('user01', '1111', 'Juan Pérez', 1500.50, 'N');
INSERT INTO USUARIOS_CUENTAS VALUES ('user02', '2222', 'Ana García', 300.00, 'N');

-- Stock inicial físico del cajero automático
INSERT INTO CAJERO_STOCK VALUES (5,  100, SYSDATE);
INSERT INTO CAJERO_STOCK VALUES (10, 50,  SYSDATE);
INSERT INTO CAJERO_STOCK VALUES (20, 200, SYSDATE);
INSERT INTO CAJERO_STOCK VALUES (50, 10,  SYSDATE);

-- Historial de movimientos iniciales para pruebas Maestro-Detalle
INSERT INTO MOVIMIENTOS VALUES (SEQ_MOVIMIENTOS.NEXTVAL, 'user01', SYSDATE-1, 'I', 50, 2, 100);
INSERT INTO MOVIMIENTOS VALUES (SEQ_MOVIMIENTOS.NEXTVAL, 'user01', SYSDATE,   'R', 20, 1, 20);
INSERT INTO MOVIMIENTOS VALUES (SEQ_MOVIMIENTOS.NEXTVAL, 'user02', SYSDATE,   'I', 10, 5, 50);

-- Confirmamos los datos permanentemente en la base de datos
COMMIT;
