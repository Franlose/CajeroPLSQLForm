-- CUERPO DEL PAQUETE (Lógica interna y transacciones)
CREATE OR REPLACE PACKAGE BODY hr.pkg_cajero IS

    --------------------------------------------------------------------
    -- T1.4: AUTENTICACIÓN DE USUARIOS
    --------------------------------------------------------------------
    PROCEDURE autenticar_usuario (
        p_id_usuario IN  hr.usuarios_cuentas.id_usuario%TYPE,
        p_pin        IN  hr.usuarios_cuentas.pin%TYPE,
        p_es_admin   OUT hr.usuarios_cuentas.es_admin%TYPE,
        p_valido     OUT BOOLEAN
    ) IS
    BEGIN
        -- Buscamos el usuario por su ID y PIN exactos
        SELECT es_admin INTO p_es_admin FROM hr.usuarios_cuentas
         WHERE id_usuario = p_id_usuario AND pin = p_pin;
           
        p_valido := TRUE;
    EXCEPTION -- T1.3
        -- Si las credenciales no coinciden, evitamos que la app se rompa
        WHEN NO_DATA_FOUND THEN p_valido := FALSE;
            p_es_admin := 'N';
    END autenticar_usuario;

    --------------------------------------------------------------------
    -- T1.5: RETIRADA DE EFECTIVO (Lógica simplificada por LOV de billete)
    --------------------------------------------------------------------
    FUNCTION retirar_dinero (
        p_id_usuario IN hr.usuarios_cuentas.id_usuario%TYPE,
        p_id_billete IN hr.tipos_billetes.id_billete%TYPE
    ) RETURN BOOLEAN IS
        v_saldo_actual  NUMBER;
        v_valor_billete NUMBER;
        v_stock_cajero  NUMBER;
    BEGIN
		-- Obtenemos el valor económico del billete seleccionado (ej: 20, 50)
        SELECT id_billete INTO v_valor_billete FROM hr.tipos_billetes WHERE id_billete = p_id_billete;

        -- Bloqueamos la cuenta y validamos si el cliente tiene saldo suficiente
        SELECT saldo INTO v_saldo_actual FROM hr.usuarios_cuentas WHERE id_usuario = p_id_usuario
           FOR UPDATE;

        IF v_saldo_actual < v_valor_billete THEN RETURN FALSE; -- Saldo insuficiente en cuenta
        END IF;

        -- Bloqueamos el stock y comprobamos si queda al menos 1 billete en el cajero
        SELECT cantidad INTO v_stock_cajero FROM hr.cajero_stock WHERE id_billete = p_id_billete
           FOR UPDATE;

        IF v_stock_cajero < 1 THEN RETURN FALSE; -- El cajero no tiene físicamente este tipo de billete
        END IF;

        -- Si todo es correcto, aplicamos los cambios transaccionales
        -- Restamos 1 unidad del stock físico del cajero
        UPDATE hr.cajero_stock SET cantidad = cantidad - 1 WHERE id_billete = p_id_billete;

        -- Restamos el importe económico del saldo del usuario
        UPDATE hr.usuarios_cuentas SET saldo = saldo - v_valor_billete WHERE id_usuario = p_id_usuario;

        -- Registramos la auditoría de la retirada en la tabla MOVIMIENTOS
        INSERT INTO hr.movimientos (
            id_mov, id_usuario, fecha, tipo_operacion, 
            id_billete, cantidad_billetes, total_importe
        ) VALUES (
            hr.seq_movimientos.NEXTVAL, p_id_usuario, SYSDATE, 'R', 
            p_id_billete, 1, v_valor_billete
        );

        RETURN TRUE; -- Operación autorizada con éxito
    EXCEPTION -- T1.3
        WHEN OTHERS THEN
            ROLLBACK; -- Deshacemos cualquier cambio en caso de error inesperado
            RAISE_APPLICATION_ERROR(-20001, 'Error crítico en el proceso de retirada.');
    END retirar_dinero;

    --------------------------------------------------------------------
    -- T1.6: INGRESO DE EFECTIVO
    --------------------------------------------------------------------
    PROCEDURE ingresar_dinero (
        p_id_usuario IN hr.usuarios_cuentas.id_usuario%TYPE,
        p_id_billete IN hr.tipos_billetes.id_billete%TYPE,
        p_cantidad   IN NUMBER
    ) IS
        v_valor_billete NUMBER;
        v_total_ingreso NUMBER;
    BEGIN
        -- Validamos que no se intenten ingresar cantidades absurdas o negativas
        IF p_cantidad <= 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'La cantidad de billetes debe ser mayor a cero.');
        END IF;

        -- Obtenemos el valor nominal del billete a ingresar
        SELECT id_billete INTO v_valor_billete FROM hr.tipos_billetes WHERE id_billete = p_id_billete;

        -- Calculamos el importe total económico (Billetes * Valor)
        v_total_ingreso := p_cantidad * v_valor_billete;

        -- Sumamos los billetes físicos al inventario del cajero
        UPDATE hr.cajero_stock SET cantidad = cantidad + p_cantidad WHERE id_billete = p_id_billete;

        -- Incrementamos el saldo en la cuenta del usuario
        UPDATE hr.usuarios_cuentas SET saldo = saldo + v_total_ingreso WHERE id_usuario = p_id_usuario;

        -- Registramos la auditoría del ingreso en la tabla MOVIMIENTOS
        INSERT INTO hr.movimientos (
            id_mov, id_usuario, fecha, tipo_operacion, 
            id_billete, cantidad_billetes, total_importe
        ) VALUES (
            hr.seq_movimientos.NEXTVAL, p_id_usuario, SYSDATE, 'I', 
            p_id_billete, p_cantidad, v_total_ingreso
        );
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20002, 'Error crítico al procesar el ingreso.');
    END ingresar_dinero;

END pkg_cajero;
/