# PCP-INSTALLER

> Instalador de software masivo para Windows con interfaz gráfica, impulsado por [Chocolatey](https://chocolatey.org/).

Un único archivo `.bat` que despliega una GUI moderna con tema oscuro para seleccionar e instalar aplicaciones habituales en equipos Windows, y ejecutar scripts de configuración del sistema. Ideal para puestas en marcha de nuevos equipos o reinstalaciones.

---

## Captura

```
 ██████╗  ██████╗██████╗      ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗
 ██╔══██╗██╔════╝██╔══██╗     ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗
 ██████╔╝██║     ██████╔╝     ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝
 ██╔═══╝ ██║     ██╔═══╝      ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗
 ██║     ╚██████╗██║          ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║
 ╚═╝      ╚═════╝╚═╝          ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
```

---

## Características

- **Un solo archivo** — sin dependencias externas, sin instalación previa
- **Elevación automática** — solicita UAC si no se ejecuta como administrador
- **Interfaz gráfica** — tema oscuro, grid de tarjetas con checkboxes por categoría
- **Chocolatey automático** — si no está instalado, lo descarga e instala solo
- **Sección de scripts** — configura el sistema con un clic (registro, energía, privacidad...)
- **Instalación no bloqueante** — la GUI permanece activa durante el proceso
- **Log en tiempo real** — salida coloreada: verde (OK), rojo (error), amarillo (aviso)
- **Seleccionar / Deseleccionar todo** — aplica a paquetes y scripts a la vez

---

## Requisitos

| Requisito | Detalle |
|---|---|
| Sistema operativo | Windows 10 / 11 |
| Permisos | Administrador (se solicita automáticamente) |
| Internet | Necesario para descargar Chocolatey y los paquetes |
| PowerShell | 5.1+ (incluido en Windows 10/11) |

---

## Uso

1. Descarga `PCP-INSTALLER.bat`
2. Haz doble clic — Windows pedirá confirmación de UAC
3. Selecciona los paquetes a instalar y/o los scripts a ejecutar
4. Pulsa **INSTALAR PAQUETES** y/o **EJECUTAR SCRIPTS**
5. Sigue el progreso en el log inferior

> También puedes ejecutarlo desde una consola elevada:
> ```bat
> PCP-INSTALLER.bat
> ```

---

## Paquetes incluidos

### ✅ Marcados por defecto

| Categoría | Aplicación | ID Chocolatey |
|---|---|---|
| Compresión | NanaZip | `nanazip` |
| Documentos | Adobe Acrobat Reader | `adobereader` |
| Multimedia | VLC Media Player | `vlc` |
| Editores | Notepad++ | `notepadplusplus` |
| Archivos | Total Commander | `totalcommander` |
| Archivos | Everything (búsqueda rápida) | `everything` |
| Java | Java JRE 21 LTS | `temurin21jre` |
| Navegadores | Google Chrome | `googlechrome` |

### ☐ Opcionales (desmarcados por defecto)

| Categoría | Aplicación | ID Chocolatey |
|---|---|---|
| Compresión | WinRAR | `winrar` |
| Compresión | 7-Zip | `7zip` |
| Editores | Visual Studio Code | `vscode` |
| Navegadores | Mozilla Firefox | `firefox` |
| Comunicación | Zoom | `zoom` |
| Comunicación | Slack | `slack` |
| Comunicación | Thunderbird | `thunderbird` |
| Comunicación | AnyDesk | `anydesk.install` |
| Comunicación | TeamViewer | `teamviewer` |
| Utilidades | ShareX | `sharex` |
| Utilidades | CPU-Z | `cpu-z` |
| Utilidades | WinDirStat | `windirstat` |
| Utilidades | PatchCleaner | `patchcleaner` |
| Utilidades | Fuentes Microsoft Core | `msttcorefonts` |
| IA | Claude Desktop | `claude` |

---

## Scripts del sistema

Scripts de configuración incluidos, ejecutables con el botón **EJECUTAR SCRIPTS**. Todos desmarcados por defecto.

| Script | Descripción |
|---|---|
| **Actualizar fecha y hora** | Activa el servicio W32Time y sincroniza contra `pool.ntp.org` forzando actualización inmediata |
| **Desactivar inicio rápido** | Desactiva Fast Startup (`HiberbootEnabled = 0`) para un apagado limpio |
| **Ajuste Energía** | Establece apagado de pantalla, suspensión y disco a **Nunca**, tanto en AC como en DC |
| **Privacidad y Telemetría** | Desactiva telemetría de Windows, servicios DiagTrack y dmwappushservice, Cortana, publicidad personalizada y sugerencias del menú inicio |
| **Limpiar archivos temporales** | Vacía `%TEMP%`, `%TMP%`, `C:\Windows\Temp`, `C:\Windows\Prefetch` y la caché de miniaturas del Explorador |

---

## Cómo añadir o quitar paquetes

Toda la lista está en el array `$paquetes` (línea ~85 del archivo). Cada entrada es un hashtable con cuatro campos:

```powershell
@{ Cat="Categoria"; Nombre="Nombre visible"; Choco="id-en-chocolatey"; Default=$true }
```

| Campo | Descripción |
|---|---|
| `Cat` | Categoría mostrada como cabecera. Si usas una nueva, se crea automáticamente. |
| `Nombre` | Texto que aparece en el checkbox. |
| `Choco` | ID del paquete en [community.chocolatey.org](https://community.chocolatey.org/packages). |
| `Default` | `$true` = marcado por defecto · `$false` = desmarcado |

### Añadir un paquete

```powershell
$paquetes = @(
    # ... paquetes existentes ...
    @{ Cat="Utilidades"; Nombre="Mi Programa"; Choco="mi-programa"; Default=$false }
)
```

La UI se regenera dinámicamente — no hay que tocar nada más.

### Eliminar un paquete

Borra la línea correspondiente del array.

### Cambiar el estado por defecto

Cambia `Default=$false` a `Default=$true` o viceversa.

---

## Cómo añadir o quitar scripts

Los scripts están en el array `$scripts`, justo antes de `$paquetes`. Cada entrada tiene este formato:

```powershell
@{
    Nombre  = "Nombre del script"
    Desc    = "Descripcion breve que aparece bajo el checkbox"
    Default = $false
    Accion  = {
        # Codigo PowerShell a ejecutar
        Set-ItemProperty -Path "HKLM:\..." -Name "Clave" -Value 1 -Type DWord -Force
    }
}
```

| Campo | Descripción |
|---|---|
| `Nombre` | Texto del checkbox en la interfaz. |
| `Desc` | Descripción corta visible bajo el nombre. |
| `Default` | `$true` = marcado por defecto · `$false` = desmarcado |
| `Accion` | Bloque de PowerShell que se ejecuta en background con privilegios de administrador. |

El script se ejecuta en un Runspace separado, por lo que la UI no se bloquea. Los errores quedan registrados en el log con detalle.

---

## Arquitectura del archivo

El archivo es un híbrido **Batch + PowerShell** en un único `.bat`:

```
PCP-INSTALLER.bat
│
├── Líneas 1–20   →  Capa Batch
│                    • Comprueba si se ejecuta como administrador
│                    • Si no, se relanza con UAC via Start-Process -Verb RunAs
│                    • Extrae y ejecuta el bloque PowerShell embebido (Skip 21)
│
└── Líneas 22–fin →  Capa PowerShell (Windows Forms)
                     • Array $scripts   →  definición de scripts del sistema
                     • Array $paquetes  →  definición de paquetes Chocolatey
                     • Construcción GUI →  header ASCII art, tarjetas, botones, log
                     • Instalacion      →  Runspace background + Chocolatey
                     • Ejecucion        →  Runspace background + scriptblocks
```

---

## Tecnologías

- **Batch (cmd.exe)** — entrada y elevación de privilegios
- **PowerShell 5.1** — lógica completa de la aplicación
- **System.Windows.Forms** — interfaz gráfica nativa de Windows
- **System.Drawing** — renderizado del ASCII art con gradiente naranja
- **Chocolatey** — gestor de paquetes para Windows
- **Runspaces de PowerShell** — instalación y ejecución de scripts en background sin bloquear la UI

---

## Licencia

MIT — úsalo, modifícalo y compártelo libremente.
