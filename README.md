# PCP-INSTALLER

> Instalador de software masivo para Windows con interfaz gráfica, impulsado por [Chocolatey](https://chocolatey.org/).

Un único archivo `.bat` que despliega una GUI moderna con tema oscuro para seleccionar e instalar de forma silenciosa un conjunto de aplicaciones habituales en equipos Windows. Ideal para puestas en marcha de nuevos equipos o reinstalaciones de sistema.

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
- **Instalación no bloqueante** — la GUI permanece activa durante el proceso (scroll del log, movimiento de ventana)
- **Log en tiempo real** — salida coloreada: verde (OK), rojo (error), amarillo (aviso)
- **Seleccionar / Deseleccionar todo** — botones de acción rápida

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
3. Selecciona los paquetes que quieres instalar
4. Pulsa **INSTALAR SELECCIONADOS**
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

## Cómo añadir o quitar paquetes

Toda la lista de paquetes está en el array `$paquetes` (aproximadamente en la **línea 29** del archivo). Cada entrada es un hashtable con cuatro campos:

```powershell
@{ Cat="Categoria"; Nombre="Nombre visible"; Choco="id-en-chocolatey"; Default=$true }
```

| Campo | Descripción |
|---|---|
| `Cat` | Categoría que se muestra como cabecera en la GUI. Si usas una nueva, se crea automáticamente. |
| `Nombre` | Texto que aparece en el checkbox dentro de la interfaz. |
| `Choco` | ID del paquete en [community.chocolatey.org](https://community.chocolatey.org/packages). |
| `Default` | `$true` = marcado por defecto · `$false` = desmarcado |

### Añadir un paquete

Busca el ID del paquete en [chocolatey.org/packages](https://community.chocolatey.org/packages) y añade una línea al array:

```powershell
$paquetes = @(
    # ... paquetes existentes ...
    @{ Cat="Utilidades"; Nombre="Mi Programa"; Choco="mi-programa"; Default=$false }
)
```

La UI se regenera dinámicamente — no hay que tocar nada más.

### Eliminar un paquete

Borra la línea correspondiente del array. Nada más.

### Cambiar si un paquete está marcado por defecto

Cambia `Default=$false` a `Default=$true` o viceversa.

### Añadir una nueva categoría

Simplemente usa un valor nuevo en el campo `Cat`. Aparecerá como un grupo nuevo en la interfaz automáticamente:

```powershell
@{ Cat="Mi Categoria"; Nombre="Alguna App"; Choco="algunaapp"; Default=$true }
```

---

## Arquitectura del archivo

El archivo es un híbrido **Batch + PowerShell** en un único `.bat`:

```
PCP-INSTALLER.bat
│
├── Líneas 1–20   →  Capa Batch
│                    • Comprueba si se ejecuta como administrador
│                    • Si no, se relanza con UAC via Start-Process -Verb RunAs
│                    • Extrae y ejecuta el bloque PowerShell embebido
│
└── Líneas 22–fin →  Capa PowerShell (Windows Forms)
                     • Array $paquetes  →  definición de la lista
                     • Construcción de la GUI  →  form, header, tarjetas, botones, log
                     • Lógica de instalación  →  Runspace en background + Chocolatey
```

La capa Batch lee el propio archivo con `Get-Content`, salta las primeras 21 líneas y ejecuta el resto como PowerShell mediante `Invoke-Expression`.

---

## Tecnologías

- **Batch (cmd.exe)** — entrada y elevación de privilegios
- **PowerShell 5.1** — lógica completa de la aplicación
- **System.Windows.Forms** — interfaz gráfica nativa de Windows
- **System.Drawing** — renderizado del ASCII art con gradiente naranja
- **Chocolatey** — gestor de paquetes para Windows
- **Runspaces de PowerShell** — instalación en background sin bloquear la UI

---

## Licencia

MIT — úsalo, modifícalo y compártelo libremente.
