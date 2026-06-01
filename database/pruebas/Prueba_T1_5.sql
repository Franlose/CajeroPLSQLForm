SET SERVEROUTPUT ON;
-- Este bloque simula que el usuario user02 (que empieza con 300€ de saldo según tus inserts)
-- intenta sacar un billete de 50€. Al terminar, lanzaremos un ROLLBACK para no alterar tus datos de prueba fijos.

DECLARE
    v_resultado BOOLEAN;
    v_saldo_aux NUMBER;
    v_stock_aux NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- PRUEBA DE RETIRADA DE DINERO ---');

    -- Ejecutamos la retirada de 1 billete de 50€ para user02
    v_resultado := hr.pkg_cajero.retirar_dinero('user02', 50);
    
    IF v_resultado THEN
        DBMS_OUTPUT.PUT_LINE('Retirada autorizada con éxito.');
        
        -- Comprobamos si restó el saldo del usuario
        SELECT saldo INTO v_saldo_aux FROM hr.usuarios_cuentas WHERE id_usuario = 'user02';
        DBMS_OUTPUT.PUT_LINE('Nuevo saldo de user02 (Esperado 250): ' || v_saldo_aux);
        
        -- Comprobamos si restó 1 unidad del stock físico del cajero (empezó en 10)
        SELECT cantidad INTO v_stock_aux FROM hr.cajero_stock WHERE id_billete = 50;
        DBMS_OUTPUT.PUT_LINE('Nuevo stock de billetes de 50 (Esperado 9): ' || v_stock_aux);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Operación rechazada (Saldo o stock insuficiente).');
    END IF;
    
    -- Deshacemos los cambios para dejar las tablas limpias para la siguiente prueba
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Rollback ejecutado. Datos restaurados.');
END;
/