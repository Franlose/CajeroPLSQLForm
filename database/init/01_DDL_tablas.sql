-- =============================================================
-- 1. ELIMINACIÓN DE OBJETOS (Por integridad referencial)
-- =============================================================
DROP TABLE MOVIMIENTOS CASCADE CONSTRAINTS;
DROP TABLE CAJERO_STOCK CASCADE CONSTRAINTS;
DROP TABLE USUARIOS_CUENTAS CASCADE CONSTRAINTS;
DROP TABLE TIPOS_BILLETES CASCADE CONSTRAINTS;
DROP SEQUENCE SEQ_MOVIMIENTOS;

-- =============================================================
-- 2. CREACIÓN DE ESTRUCTURAS (DDL)
-- =============================================================

-- Catálogo de billetes (Alimenta la LOV)
CREATE TABLE TIPOS_BILLETES (
    id_billete  NUMBER(3) PRIMARY KEY,
    descripcion VARCHAR2(50) NOT NULL
);

-- Usuarios y Cuentas (Soporta Autenticación y Saldo Maestro)
CREATE TABLE USUARIOS_CUENTAS (
    id_usuario  VARCHAR2(20) PRIMARY KEY,
    pin         VARCHAR2(4) NOT NULL,
    nombre      VARCHAR2(100) NOT NULL,
    saldo       NUMBER(12,2) DEFAULT 0,
    es_admin    CHAR(1) DEFAULT 'N',
    CONSTRAINT ck_pin_format CHECK (LENGTH(pin) = 4),
    CONSTRAINT ck_admin_flag CHECK (es_admin IN ('S', 'N')),
    CONSTRAINT ck_saldo_negativo CHECK (saldo >= 0)
);

-- Inventario del Cajero (Llenado por el Administrador)
CREATE TABLE CAJERO_STOCK (
    id_billete       NUMBER(3) PRIMARY KEY,
    cantidad         NUMBER(10) DEFAULT 0,
    ultima_carga     DATE DEFAULT SYSDATE,
    CONSTRAINT fk_stock_tipo FOREIGN KEY (id_billete) REFERENCES TIPOS_BILLETES(id_billete),
    CONSTRAINT ck_stock_minimo CHECK (cantidad >= 0)
);

-- Historial de Movimientos (Detalle del Usuario)
CREATE TABLE MOVIMIENTOS (
    id_mov            NUMBER PRIMARY KEY,
    id_usuario        VARCHAR2(20),
    fecha             DATE DEFAULT SYSDATE,
    tipo_operacion    VARCHAR2(1), -- 'I' para Ingreso, 'R' para Retirada
    id_billete        NUMBER(3),
    cantidad_billetes NUMBER(5),
    total_importe     NUMBER(12,2),
    CONSTRAINT fk_mov_usuario FOREIGN KEY (id_usuario) REFERENCES USUARIOS_CUENTAS(id_usuario),
    CONSTRAINT fk_mov_tipo_billete FOREIGN KEY (id_billete) REFERENCES TIPOS_BILLETES(id_billete),
    CONSTRAINT ck_tipo_op CHECK (tipo_operacion IN ('I', 'R'))
);

-- Secuencia para los identificadores de movimientos
CREATE SEQUENCE SEQ_MOVIMIENTOS START WITH 1 INCREMENT BY 1;
