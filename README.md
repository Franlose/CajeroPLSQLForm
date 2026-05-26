# 🏧 Sistema de Cajero Automático (Oracle Forms & PL/SQL)

Aplicación modular de cajero automático desarrollada sobre la base de datos Oracle (esquema `HR`), utilizando **Oracle Forms Developer** para la capa de presentación y **PL/SQL** para la lógica de negocio distribuida.

---

## 🏛️ Arquitectura del Sistema

El proyecto sigue una arquitectura clásica de tres niveles para garantizar la seguridad de las transacciones y la reutilización de componentes visuales:

[ BASE DE DATOS (Esquema: HR) ]
└── Tablas ── Paquete PL/SQL (PKG_CAJERO) ── Triggers de BD
▲
│ SQL / PL/SQL nativo
▼
[ CAPA DE PRESENTACIÓN (Oracle Forms - 2 Ventanas Obligatorias) ]
├── WINDOW_LOGIN (Canvas de Acceso)
└── WINDOW_PRINCIPAL (Canvases de Operaciones)
├── Canvas Cliente: Consultas, Retiradas (LOV), Ingresos.
└── Canvas Admin: Llenado de Billetes, Exportación Local.

---

## 📂 Estructura del Repositorio

```text
├── database/               # Objetos de Base de Datos (PL/SQL)
│   ├── Tablas
│   │	├── #De moneto solo el sql de prueba.
│   │	├── DDL_tablas.sql      # Creación de tablas, llaves y restricciones
│   │   └── DDL_secuencias.sql  # Secuencias para IDs automáticos
│   └── Packages
│       └── PKG_CAJERO.sql      # Especificación y cuerpo del paquete lógico
│
├── src/
│   └── forms/                  		 # Componentes de Oracle Forms Developer
│       ├── CAJERO_AUTOMATICO.fmb        # Archivo fuente del formulario principal
│       └── CAJERO_AUTOMATICO.fmx        # Binario compilado listo para ejecución
│
├── README.md               # Documentación general del proyecto
└── .gitignore              # Filtra ejecutables (*.plx)
```

---

## 📊 Modelo de Datos (Esquema `HR`)

El sistema se compone de 4 tablas principales interconectadas:
*   **`HR.USUARIOS_CUENTAS`**: Almacena credenciales (`PIN`), saldos actuales y el rol (`ES_ADMIN`).
*   **`HR.MOVIMIENTOS`**: Historial auditable de ingresos y retiradas (**Relación Maestro-Detalle** con cuentas).
*   **`HR.TIPOS_BILLETES`**: Catálogo maestro de denominaciones de billetes válidos (ej: 10, 20, 50).
*   **`HR.CAJERO_STOCK`**: Control central del inventario físico y disponibilidad de billetes en el cajero.

---

## 🛠️ Especificaciones de Implementación

### 1. Capa de Base de Datos (PL/SQL)
*   **`PKG_CAJERO`**: Concentra la lógica transaccional. Evita que el formulario realice operaciones directas en las tablas, mejorando la seguridad.
*   **Control de Stock**: El procedimiento de retirada calcula mediante un algoritmo la cantidad óptima de billetes a entregar y verifica la existencia en `CAJERO_STOCK` antes de descontar el saldo.

### 2. Capa de Presentación (Oracle Forms)
*   **Estructura de Ventanas**: Dividido estrictamente en **dos ventanas**. La ventana principal intercambia sus canvases de forma dinámica según los privilegios del usuario autenticado.
*   **Objetos Reutilizables**:
    *   **Clases de Propiedad**: Aplicadas a campos de tipo *Fecha*, *Importe* y *Códigos* para estandarizar formatos y validaciones.
    *   **Alertas**: Mensajes emergentes genéricos parametrizados para confirmaciones críticas (ej. salir del sistema, confirmar retiro).
    *   **LOV (List of Values)**: Lista dinámica basada en `TIPOS_BILLETES` para la selección del tipo de billete en el canvas de ingreso/retirada.
*   **Triggers Obligatorios**: Implementación nativa a nivel de formulario para `ON-ERROR` (captura centralizada de excepciones de BD) y `ON-LOGON` (conexión segura al esquema).
*   **Componentes Interactivos**: Inclusión de un **Menú Contextual** (Popup Menu) asociado a los bloques de datos principales para agilizar la navegación del usuario.

### 3. Módulos de Reportes (Perfil Administrador)
*   **Exportación de Caja**: Rutina integrada que genera un archivo plano de texto local (`.txt`) con el desglose actual del inventario de billetes y el balance general del cajero.

---

## 🚀 Instrucciones de Despliegue

1.  **Ejecutar Scripts de BD**: Vuele el contenido de la carpeta `/database` en su herramienta SQL (SQL Developer, PL/SQL Developer) conectado al usuario `hr`.
2.  **Compilar Formulario**: Abra `CAJERO_AUTOMATICO.fmb` en Oracle Forms Builder y genere el archivo ejecutable (`Ctrl + T`) para crear el `.fmx`.
3.  **Configurar Runtime**: Asegúrese de que la ruta de la carpeta `/forms` se encuentre en la variable de entorno `FORMS_PATH` de su servidor de aplicaciones o registro local.