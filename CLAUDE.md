# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Windows batch/PowerShell hybrid installer utility (`instalar_software.bat`) that presents a GUI for batch-installing applications via the Chocolatey package manager. It requires administrator privileges and is Windows-only.

## Running the Script

```bat
instalar_software.bat
```

Double-click or run from an elevated command prompt. The batch layer automatically requests UAC elevation if needed.

## Architecture

The single file `instalar_software.bat` has two layers:

**Batch layer (lines 1–20):** Entry point — checks for admin rights and re-launches itself via PowerShell with elevation if needed. The PowerShell payload is extracted by skipping the first 17 lines of the file.

**PowerShell GUI layer (lines 22–314):** A Windows Forms application with a dark theme (Indigo/Slate palette). Key sections:

- **`$paquetes` array (lines 29–50):** Array of hashtables defining each installable package — `Categoria`, `Nombre` (display name), `Paquete` (Chocolatey ID), and `Seleccionado` (default checkbox state).
- **UI construction (lines 52–223):** Dark-themed form, scrollable two-column package card grid, header with live package counter, Select All / Deselect All / Install buttons.
- **Installation logic (lines 246–311):** On install click — bootstraps Chocolatey if absent, then installs each selected package using `choco install` with `-y --no-progress`, streaming output to the embedded log panel with color-coded lines (green = success, red = error, yellow = warning).

## Adding or Removing Packages

Edit the `$paquetes` array. Each entry follows this pattern:

```powershell
@{ Categoria="CategoryName"; Nombre="Display Name"; Paquete="chocolatey-id"; Seleccionado=$true }
```

The UI is generated dynamically from this array, so no UI code needs to change when adding packages.

## Key Constraints

- Chocolatey must be installable (requires internet access on first run).
- The script uses `System.Windows.Forms` — it will not work in non-interactive or headless environments.
- Font used throughout: Segoe UI (standard on Windows 10/11).
