-- ====================================================================
-- PAQUETE: PKG_CAJERO (Especificación y Cuerpo)
-- Adaptado al modelo físico real del repositorio
-- ====================================================================

-- ESPECIFICACIÓN DEL PAQUETE (Interfaz pública para Oracle Forms)
CREATE OR REPLACE PACKAGE hr.pkg_cajero IS
	
	-- Procedimiento para validar el acceso al cajero
    PROCEDURE autenticar_usuario (
        p_id_usuario IN  hr.usuarios_cuentas.id_usuario%TYPE,
        p_pin        IN  hr.usuarios_cuentas.pin%TYPE,
        p_es_admin   OUT hr.usuarios_cuentas.es_admin%TYPE,
        p_valido     OUT BOOLEAN
    );
	
	-- Función simplificada para procesar una retirada de un billete específico
    FUNCTION retirar_dinero (
        p_id_usuario IN hr.usuarios_cuentas.id_usuario%TYPE,
        p_id_billete IN hr.tipos_billetes.id_billete%TYPE
    ) RETURN BOOLEAN;
	
	-- Procedimiento para ingresar dinero (unidades de un billete específico)
    PROCEDURE ingresar_dinero (
        p_id_usuario IN hr.usuarios_cuentas.id_usuario%TYPE,
        p_id_billete IN hr.tipos_billetes.id_billete%TYPE,
        p_cantidad   IN NUMBER
    );

END pkg_cajero;
/
