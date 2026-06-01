SET SERVEROUTPUT ON;
-- Este bloque simula que el usuario user02 ingresa 3 billetes de 20€ (Importe total: 60€). 
-- Su saldo debería subir de 300€ a 360€, y el stock de billetes de 20€ debería aumentar en 3 unidades.

DECLARE
    v_saldo_aux NUMBER;
    v_stock_aux NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- PRUEBA DE INGRESO DE DINERO ---');

    -- Simulamos el ingreso: 3 billetes de 20€
    hr.pkg_cajero.ingresar_dinero('user02', 20, 3);
    
    -- Comprobamos saldo incrementado (300 + 60 = 360)
    SELECT saldo INTO v_saldo_aux FROM hr.usuarios_cuentas WHERE id_usuario = 'user02';
    DBMS_OUTPUT.PUT_LINE('Nuevo saldo de user02 (Esperado 360): ' || v_saldo_aux);
    
    -- Comprobamos stock incrementado (empezó en 200 + 3 = 203)
    SELECT cantidad INTO v_stock_aux FROM hr.cajero_stock WHERE id_billete = 20;
    DBMS_OUTPUT.PUT_LINE('Nuevo stock de billetes de 20 (Esperado 203): ' || v_stock_aux);
    
    -- Deshacemos cambios para mantener las tablas intactas
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Rollback ejecutado. Datos restaurados.');
END;
/