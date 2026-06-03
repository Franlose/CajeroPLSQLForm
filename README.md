# 🏧 Sistema de Cajero Automático (Oracle Forms & PL/SQL)

Aplicación modular de cajero automático desarrollada sobre la base de datos Oracle (esquema `HR`), utilizando **Oracle Forms Developer** para la capa de presentación estructurada en módulos independientes y **PL/SQL** para la lógica de negocio centralizada.

---

## 🏛️ Arquitectura Modular del Sistema

El proyecto ha evolucionado de un diseño monolítico a un ecosistema de componentes desacoplados para garantizar la reutilización de objetos visuales y la seguridad en la navegación:
```text
[ LIBRERÍA DE OBJETOS COMPARTIDOS (TEMPLATE_ATM.olb) ] ── Conectada a las pantallas
├── Alertas Estándar (Confirmación, Errores, Bloqueos)
├── Clases de Propiedad (Estilos unificados para Fechas, Importes y PINs)
└── Menú Contextual (Popup Menu genérico para interacciones rápidas con clic derecho)
│
▼ Herencia visual directa (Subclassing)[ FORMULARIO 1: LOGIN_ATM.fmb ] ───────────► [ FORMULARIO 2: CAJERO_AUTOMATICO.fmb ]
- Triggers ON-LOGON / ON-ERROR - Interfaz principal de operaciones.
- Control de 3 intentos de PIN. - Carga dinámica de Canvases según rol.
- Abre el cajero mediante CALL_FORM - Relación Maestro-Detalle de movimientos.transfiriendo parámetros de usuario. - Control de cierre de sesión (Logout).
```

---

## 📂 Estructura del Repositorio

```text
├── database/               # Componentes de Base de Datos (PL/SQL)
│   ├── init/               # Scripts de inicialización del entorno
│   │   ├── 01_DDL_tablas.sql             # Estructura, llaves y restricciones
│   │   ├── 02_DML_inserts.sql            # Usuarios, billetes y stock de prueba
│   │   └── 03_queries_verificacion.sql   # Consulta de auditoría interna
│   │
│   ├── packages/           # API transaccional
│   │   ├── PKG_CAJERO_PKS.sql            # Especificación del paquete (Menu)
│   │   └── PKG_CAJERO_PKB.sql            # Cuerpo del paquete (Cocina interna)
│   │
│   └── pruebas/            # Scripts de aseguramiento de calidad
│       ├── Prueba_T1_4.sql               # Test de la lógica de Autenticación
│       ├── Prueba_T1_5.sql               # Test del proceso de Retiradas
│       └── Prueba_T1_6.sql               # Test del proceso de Ingresos
│
├── forms/                  # Componentes de Oracle Forms Developer
│   ├── TEMPLATE.olb    # Librería de Objetos (Alertas y Clases de Propiedad fijos)
│   ├── LOGIN.fmb       # Código fuente de la pantalla de acceso y seguridad
│   └── CAJERO_AUTOMATICO.fmb # Código fuente de la pantalla de operaciones bancarias
│
└── README.md               # Documentación general del proyecto
```

---

## 📊 Modelo de Datos (Esquema `HR`)

El sistema se compone de 4 tablas principales interconectadas:
*   **`HR.USUARIOS_CUENTAS`**: Almacena credenciales (`PIN`), saldos actuales y el rol (`ES_ADMIN`).
*   **`HR.MOVIMIENTOS`**: Historial auditable de ingresos y retiradas (**Relación Maestro-Detalle** con cuentas).
*   **`HR.TIPOS_BILLETES`**: Catálogo maestro de denominaciones de billetes válidos (ej: 10, 20, 50).
*   **`HR.CAJERO_STOCK`**: Control central del inventario físico y disponibilidad de billetes en el cajero.

---

## 🔐 Componentes Destacados de la Implementación

### 1. Sistema de Plantillas y Reutilización (`.olb`)
Para evitar duplicar configuraciones estéticas, se ha creado la librería `TEMPLATE_ATM.olb`. Los formularios heredan por *Subclassing* las **Clases de Propiedad** (garantizando máscaras uniformes para monedas `999G990D92€` y fechas `DD/MM/YYYY`) y las **Alertas**, centralizando el diseño visual.

### 2. Control de Seguridad en el Acceso (`LOGIN_ATM`)
El formulario de entrada gestiona de forma aislada la seguridad mediante un contador estricto de intentos de PIN. Invoca al procedimiento remoto `autenticar_usuario`. Si el cliente introduce una clave inválida en 3 ocasiones consecutivas, el sistema lanza una alerta de bloqueo y fuerza un cierre total (`EXIT_FORM`).

### 3. Transferencia Dinámica de Sesión
Tras un acceso exitoso, el módulo de login empaqueta el identificador del usuario y su rol (`ES_ADMIN`) en una lista de parámetros nativa, invocando a `CAJERO_AUTOMATICO.fmx` mediante `CALL_FORM`. Al cargar, el nuevo formulario lee estos datos para ocultar o mostrar las pestañas de administración de stock de forma automática.

### 4. Interfaz Basada en LOV y Relaciones Maestro-Detalle
*   **Selección por LOV:** El cliente no escribe importes libres para la retirada. Utiliza una Lista de Valores desplegable (LOV) que lee el stock de billetes reales.
*   **Sincronización Nativa:** El bloque de la cuenta actúa como maestro de un bloque multi-registro conectado a `MOVIMIENTOS`, pintando el historial de operaciones automáticamente gracias al trigger integrado de Oracle Forms.

### 5. Reportes mediante `TEXT_IO`
El perfil administrador dispone de un botón exclusivo para auditar la caja física. El formulario ejecuta un bucle que escribe línea a línea el inventario actual de billetes, exportándolo a un archivo plano `.txt` de almacenamiento local.

### 6. Menú Contextual Global (Popup Menu)
Para cumplir con las directrices de diseño interactivo y usabilidad avanzada en Oracle Forms, se ha integrado un Menú Contextual nativo dentro de la librería compartida. Este componente permite al usuario realizar un clic derecho sobre cualquier campo de texto editable del cajero automático (como el campo de ingreso o retirada de efectivo) para desplegar opciones rápidas de control de la interfaz (ej: "Limpiar Campo" o "Ver Ayuda"), reduciendo la dependencia estricta de botones físicos en la pantalla.

---

## 🚀 Instrucciones de Despliegue

1.  **Preparar BD**: Ejecuta secuencialmente los scripts de la carpeta `/database/init/` y compila las cabeceras/cuerpos de la carpeta `/database/packages/`.
2.  **Enlazar Librería**: Al abrir los fuentes `.fmb` en tu entorno local, asegúrate de abrir también `TEMPLATE_ATM.olb` en el explorador de objetos para que las referencias por herencia carguen correctamente.
3.  **Compilar Ejecutables**: Genera los archivos binarios (`Ctrl + T`) en Forms Builder asegurando que los archivos resultantes `.fmx` coexistan en el mismo directorio de ejecución para permitir la llamada entre pantallas.
