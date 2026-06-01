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
    EXCEPTION
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

        RETURN False; -- Pendiente del punto 1.5
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
        NULL; -- Código pendiente del punto 1.6
    END ingresar_dinero;

END pkg_cajero;
/