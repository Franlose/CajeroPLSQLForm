SET SERVEROUTPUT ON;
-- Este bloque simula dos intentos de login: uno correcto con un usuario de tus inserts (user01)
-- y uno fallido para comprobar que el "portero" funciona bien.
DECLARE
    v_es_admin CHAR(1);
    v_valido   BOOLEAN;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- PRUEBA DE AUTENTICACIÓN ---');
    
    -- INTENTO 1: Credenciales correctas
    hr.pkg_cajero.autenticar_usuario('user01', '1111', v_es_admin, v_valido);
    IF v_valido THEN
        DBMS_OUTPUT.PUT_LINE('Intento 1 (Éxito esperado): OK. Es Admin? ' || v_es_admin);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Intento 1 (Éxito esperado): FALLÓ.');
    END IF;

    -- INTENTO 2: PIN Incorrecto
    hr.pkg_cajero.autenticar_usuario('user01', '9999', v_es_admin, v_valido);
    IF NOT v_valido THEN
        DBMS_OUTPUT.PUT_LINE('Intento 2 (Fallo esperado): OK. Acceso denegado correctamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Intento 2 (Fallo esperado): MAL. Dejó pasar un PIN falso.');
    END IF;
END;
/