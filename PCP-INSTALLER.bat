@echo off
:: ============================================================
::  INSTALADOR GUI — Todo en un solo archivo .bat
::  Doble clic para ejecutar (pide admin automaticamente)
:: ============================================================

:: Reescalar con privilegios de administrador si hace falta
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

:: Extraer y ejecutar el bloque PowerShell embebido en este archivo
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$lines = Get-Content -LiteralPath '%~f0' -Encoding UTF8;" ^
    "$ps = ($lines | Select-Object -Skip 21) -join [Environment]::NewLine;" ^
    "Invoke-Expression $ps"
exit /b

# ================================================================
# POWERSHELL — A partir de aqui todo es PowerShell
# ================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$paquetes = @(
    @{ Cat="Compresion";   Nombre="NanaZip";                      Choco="nanazip";         Default=$true  },
    @{ Cat="Compresion";   Nombre="WinRAR";                       Choco="winrar";          Default=$false },
    @{ Cat="Compresion";   Nombre="7-Zip";                        Choco="7zip";            Default=$false },
    @{ Cat="Documentos";   Nombre="Adobe Acrobat Reader";         Choco="adobereader";     Default=$true  },
    @{ Cat="Multimedia";   Nombre="VLC Media Player";             Choco="vlc";             Default=$true  },
    @{ Cat="Editores";     Nombre="Notepad++";                    Choco="notepadplusplus"; Default=$true  },
    @{ Cat="Editores";     Nombre="Visual Studio Code";           Choco="vscode";          Default=$false },
    @{ Cat="Archivos";     Nombre="Total Commander";              Choco="totalcommander";  Default=$true  },
    @{ Cat="Archivos";     Nombre="Everything (busqueda rapida)"; Choco="everything";      Default=$true  },
    @{ Cat="Java";         Nombre="Java JRE 21 LTS (escritorio)"; Choco="temurin21jre";    Default=$true  },
    @{ Cat="Navegadores";  Nombre="Google Chrome";                Choco="googlechrome";    Default=$true  },
    @{ Cat="Navegadores";  Nombre="Mozilla Firefox";              Choco="firefox";         Default=$false },
    @{ Cat="Comunicacion"; Nombre="Zoom";                         Choco="zoom";            Default=$false },
    @{ Cat="Comunicacion"; Nombre="Slack";                        Choco="slack";           Default=$false },
    @{ Cat="Comunicacion"; Nombre="Thunderbird (correo)";         Choco="thunderbird";     Default=$false },
    @{ Cat="Comunicacion"; Nombre="AnyDesk";                      Choco="anydesk.install"; Default=$false },
    @{ Cat="Comunicacion"; Nombre="TeamViewer";                   Choco="teamviewer";      Default=$false },
    @{ Cat="Utilidades";   Nombre="ShareX (capturas pantalla)";   Choco="sharex";          Default=$false },
    @{ Cat="Utilidades";   Nombre="CPU-Z (info hardware)";        Choco="cpu-z";           Default=$false },
    @{ Cat="Utilidades";   Nombre="WinDirStat (uso de disco)";    Choco="windirstat";      Default=$false },
    @{ Cat="Utilidades";   Nombre="PatchCleaner";                 Choco="patchcleaner";    Default=$false },
    @{ Cat="Utilidades";   Nombre="Fuentes Microsoft Core";       Choco="msttcorefonts";   Default=$false },
    @{ Cat="IA";           Nombre="Claude Desktop";               Choco="claude";          Default=$false }
)

$scripts = @(
    @{
        Nombre  = "Actualizar fecha y hora"
        Desc    = "Sincroniza la fecha y hora del sistema contra servidores NTP de internet"
        Default = $false
        Accion  = {
            # Asegurar que el servicio W32tm esta activo
            Set-Service -Name "W32Time" -StartupType Automatic -ErrorAction SilentlyContinue
            Start-Service -Name "W32Time" -ErrorAction SilentlyContinue
            # Registrar y sincronizar contra pool NTP publico
            & w32tm /config /manualpeerlist:"pool.ntp.org,0.pool.ntp.org,1.pool.ntp.org" /syncfromflags:manual /reliable:YES /update | Out-Null
            & w32tm /resync /force | Out-Null
        }
    },
    @{
        Nombre  = "Desactivar inicio rapido"
        Desc    = "Desactiva Fast Startup (opcion de energia)"
        Default = $false
        Accion  = {
            $p = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
            Set-ItemProperty -Path $p -Name "HiberbootEnabled" -Value 0 -Type DWord -Force
        }
    },
    @{
        Nombre  = "Ajuste Energia: pantalla y suspension a Nunca"
        Desc    = "Apagado de pantalla y suspension en Nunca (AC y DC)"
        Default = $false
        Accion  = {
            powercfg /change monitor-timeout-ac 0
            powercfg /change standby-timeout-ac 0
            powercfg /change disk-timeout-ac 0
            powercfg /change monitor-timeout-dc 0
            powercfg /change standby-timeout-dc 0
            powercfg /change disk-timeout-dc 0
        }
    },
    @{
        Nombre  = "Privacidad y Telemetria"
        Desc    = "Desactiva telemetria, DiagTrack, Cortana, publicidad y sugerencias"
        Default = $false
        Accion  = {
            $pDC = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
            if (-not (Test-Path $pDC)) { New-Item -Path $pDC -Force | Out-Null }
            Set-ItemProperty -Path $pDC -Name "AllowTelemetry" -Value 0 -Type DWord -Force
            Stop-Service "DiagTrack"        -Force -ErrorAction SilentlyContinue
            Set-Service  "DiagTrack"        -StartupType Disabled -ErrorAction SilentlyContinue
            Stop-Service "dmwappushservice" -Force -ErrorAction SilentlyContinue
            Set-Service  "dmwappushservice" -StartupType Disabled -ErrorAction SilentlyContinue
            $pAd = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
            if (-not (Test-Path $pAd)) { New-Item -Path $pAd -Force | Out-Null }
            Set-ItemProperty -Path $pAd -Name "Enabled" -Value 0 -Type DWord -Force
            $pCo = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
            if (-not (Test-Path $pCo)) { New-Item -Path $pCo -Force | Out-Null }
            Set-ItemProperty -Path $pCo -Name "AllowCortana" -Value 0 -Type DWord -Force
            $pCd = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            Set-ItemProperty -Path $pCd -Name "SystemPaneSuggestionsEnabled"    -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $pCd -Name "SubscribedContent-338388Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $pCd -Name "SubscribedContent-310093Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        }
    },
    @{
        Nombre  = "Limpiar archivos temporales"
        Desc    = "Vacia TEMP, TMP, Windows\Temp, Prefetch y cache de miniaturas"
        Default = $false
        Accion  = {
            $paths = @($env:TEMP, $env:TMP, "C:\Windows\Temp", "C:\Windows\Prefetch")
            foreach ($p in $paths) {
                if (Test-Path $p) {
                    Get-ChildItem -Path $p -Recurse -ErrorAction SilentlyContinue |
                        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
            $th = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
            if (Test-Path $th) {
                Get-ChildItem -Path $th -Filter "thumbcache_*.db" -ErrorAction SilentlyContinue |
                    Remove-Item -Force -ErrorAction SilentlyContinue
            }
        }
    }
)

$cFondo   = [System.Drawing.Color]::FromArgb(18,  18,  24 )
$cPanel   = [System.Drawing.Color]::FromArgb(28,  28,  38 )
$cTarjeta = [System.Drawing.Color]::FromArgb(38,  38,  52 )
$cAcento  = [System.Drawing.Color]::FromArgb(99,  102, 241)
$cAcentoH = [System.Drawing.Color]::FromArgb(129, 140, 248)
$cTexto   = [System.Drawing.Color]::FromArgb(226, 232, 240)
$cSub     = [System.Drawing.Color]::FromArgb(100, 116, 139)
$cBorde   = [System.Drawing.Color]::FromArgb(51,  51,  71 )
$cOK      = [System.Drawing.Color]::FromArgb(34,  197, 94 )
$cError   = [System.Drawing.Color]::FromArgb(239, 68,  68 )
$cWarn    = [System.Drawing.Color]::FromArgb(251, 191, 36 )
$cScript  = [System.Drawing.Color]::FromArgb(20,  184, 166)

$fTitulo  = New-Object System.Drawing.Font("Segoe UI", 15,  [System.Drawing.FontStyle]::Bold)
$fSub     = New-Object System.Drawing.Font("Segoe UI", 9,   [System.Drawing.FontStyle]::Regular)
$fCat     = New-Object System.Drawing.Font("Segoe UI", 7.5, [System.Drawing.FontStyle]::Bold)
$fItem    = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Regular)
$fBtn     = New-Object System.Drawing.Font("Segoe UI", 10,  [System.Drawing.FontStyle]::Bold)
$fLog     = New-Object System.Drawing.Font("Consolas", 8.5, [System.Drawing.FontStyle]::Regular)
$fAscii   = New-Object System.Drawing.Font("Consolas", 8,   [System.Drawing.FontStyle]::Bold)

$asciiArt = @(
    ' ██████╗  ██████╗██████╗      ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗ ',
    ' ██╔══██╗██╔════╝██╔══██╗     ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗',
    ' ██████╔╝██║     ██████╔╝     ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝',
    ' ██╔═══╝ ██║     ██╔═══╝      ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗',
    ' ██║     ╚██████╗██║          ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║ ',
    ' ╚═╝      ╚═════╝╚═╝          ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝')

$asciiColors = @(
    [System.Drawing.Color]::FromArgb(210, 45,  0  ),
    [System.Drawing.Color]::FromArgb(240, 85,  0  ),
    [System.Drawing.Color]::FromArgb(255, 130, 0  ),
    [System.Drawing.Color]::FromArgb(255, 175, 10 ),
    [System.Drawing.Color]::FromArgb(255, 210, 30 ),
    [System.Drawing.Color]::FromArgb(255, 240, 70 ))

$form = New-Object System.Windows.Forms.Form
$form.Text            = "PCP-INSTALLER — Instalador de Software"
$form.Size            = New-Object System.Drawing.Size(780, 770)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $cFondo
$form.ForeColor       = $cTexto
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox     = $false
$form.Font            = $fItem

$panelHeader = New-Object System.Windows.Forms.Panel
$panelHeader.Size      = New-Object System.Drawing.Size(780, 122)
$panelHeader.Location  = New-Object System.Drawing.Point(0, 0)
$panelHeader.BackColor = $cPanel
$form.Controls.Add($panelHeader)

$panelHeader.Add_Paint({
    param($s, $e)
    $g = $e.Graphics
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
    for ($i = 0; $i -lt $asciiArt.Count; $i++) {
        $br = New-Object System.Drawing.SolidBrush($asciiColors[$i])
        $g.DrawString($asciiArt[$i], $fAscii, $br, [float]4, [float](4 + $i * 12))
        $br.Dispose()
    }
    # linea naranja brillante bajo el arte
    $brLine = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 120, 0))
    $e.Graphics.FillRectangle($brLine, 0, 80, 780, 2)
    $brLine.Dispose()
})

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text      = "  Selecciona paquetes a instalar y scripts a ejecutar"
$lblSub.Font      = $fSub
$lblSub.ForeColor = $cSub
$lblSub.Location  = New-Object System.Drawing.Point(20, 92)
$lblSub.Size      = New-Object System.Drawing.Size(500, 20)
$lblSub.BackColor = [System.Drawing.Color]::Transparent
$panelHeader.Controls.Add($lblSub)

$lblContador = New-Object System.Windows.Forms.Label
$lblContador.Font      = $fSub
$lblContador.ForeColor = [System.Drawing.Color]::FromArgb(255, 160, 0)
$lblContador.Location  = New-Object System.Drawing.Point(560, 92)
$lblContador.Size      = New-Object System.Drawing.Size(200, 20)
$lblContador.TextAlign = "MiddleRight"
$lblContador.BackColor = [System.Drawing.Color]::Transparent
$panelHeader.Controls.Add($lblContador)

$panelScroll = New-Object System.Windows.Forms.Panel
$panelScroll.Location    = New-Object System.Drawing.Point(12, 130)
$panelScroll.Size        = New-Object System.Drawing.Size(756, 420)
$panelScroll.BackColor   = $cFondo
$panelScroll.AutoScroll  = $true
$panelScroll.BorderStyle = "None"
$form.Controls.Add($panelScroll)

$checkboxes       = @{}
$checkboxesScripts = @{}
$scriptActions     = @{}
$categorias = $paquetes | ForEach-Object { $_.Cat } | Select-Object -Unique
$COL_W = 358; $COL_GAP = 12
$col = 0; $yLeft = 8; $yRight = 8

foreach ($cat in $categorias) {
    $items = $paquetes | Where-Object { $_.Cat -eq $cat }
    $x = if ($col -eq 0) { 6 } else { 6 + $COL_W + $COL_GAP }
    $y = if ($col -eq 0) { $yLeft } else { $yRight }

    $lblCat = New-Object System.Windows.Forms.Label
    $lblCat.Text      = $cat.ToUpper()
    $lblCat.Font      = $fCat
    $lblCat.ForeColor = $cSub
    $lblCat.Location  = New-Object System.Drawing.Point($x, $y)
    $lblCat.Size      = New-Object System.Drawing.Size(340, 18)
    $lblCat.BackColor = [System.Drawing.Color]::Transparent
    $panelScroll.Controls.Add($lblCat)
    $y += 20

    foreach ($pkg in $items) {
        $card = New-Object System.Windows.Forms.Panel
        $card.Size      = New-Object System.Drawing.Size(348, 36)
        $card.Location  = New-Object System.Drawing.Point($x, $y)
        $card.BackColor = $cTarjeta
        $card.Cursor    = "Hand"
        $panelScroll.Controls.Add($card)

        $cb = New-Object System.Windows.Forms.CheckBox
        $cb.Text      = $pkg.Nombre
        $cb.Checked   = $pkg.Default
        $cb.Tag       = $pkg.Choco
        $cb.Font      = $fItem
        $cb.ForeColor = $cTexto
        $cb.BackColor = $cTarjeta
        $cb.Location  = New-Object System.Drawing.Point(10, 7)
        $cb.Size      = New-Object System.Drawing.Size(330, 22)
        $cb.FlatStyle = "Flat"
        $card.Controls.Add($cb)
        $checkboxes[$pkg.Choco] = $cb

        $card.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 68) })
        $card.Add_MouseLeave({ $this.BackColor = $cTarjeta })
        $card.Add_Click({ $this.Controls[0].Checked = -not $this.Controls[0].Checked })
        $cb.Add_CheckedChanged({
            $s = ($checkboxes.Values | Where-Object { $_.Checked }).Count
            $lblContador.Text = "$s de $($checkboxes.Count) seleccionados"
        })
        $y += 42
    }
    $y += 10
    if ($col -eq 0) { $yLeft = $y; $col = 1 } else { $yRight = $y; $col = 0 }
}

$s0 = ($checkboxes.Values | Where-Object { $_.Checked }).Count
$lblContador.Text = "$s0 de $($checkboxes.Count) seleccionados"

# ── Seccion SCRIPTS ──────────────────────────────────────────
$ySc = [Math]::Max($yLeft, $yRight) + 14

$sepSc = New-Object System.Windows.Forms.Panel
$sepSc.Size      = New-Object System.Drawing.Size(724, 1)
$sepSc.Location  = New-Object System.Drawing.Point(6, $ySc)
$sepSc.BackColor = $cBorde
$panelScroll.Controls.Add($sepSc)
$ySc += 10

$lblSecScripts = New-Object System.Windows.Forms.Label
$lblSecScripts.Text      = "SCRIPTS DEL SISTEMA"
$lblSecScripts.Font      = $fCat
$lblSecScripts.ForeColor = $cScript
$lblSecScripts.Location  = New-Object System.Drawing.Point(6, $ySc)
$lblSecScripts.Size      = New-Object System.Drawing.Size(724, 18)
$lblSecScripts.BackColor = [System.Drawing.Color]::Transparent
$panelScroll.Controls.Add($lblSecScripts)
$ySc += 22

foreach ($scr in $scripts) {
    $scriptActions[$scr.Nombre] = $scr.Accion.ToString()

    $cardSc = New-Object System.Windows.Forms.Panel
    $cardSc.Size      = New-Object System.Drawing.Size(724, 48)
    $cardSc.Location  = New-Object System.Drawing.Point(6, $ySc)
    $cardSc.BackColor = $cTarjeta
    $cardSc.Cursor    = "Hand"
    $panelScroll.Controls.Add($cardSc)

    $cbSc = New-Object System.Windows.Forms.CheckBox
    $cbSc.Text      = $scr.Nombre
    $cbSc.Checked   = $scr.Default
    $cbSc.Tag       = $scr.Nombre
    $cbSc.Font      = $fItem
    $cbSc.ForeColor = $cTexto
    $cbSc.BackColor = $cTarjeta
    $cbSc.Location  = New-Object System.Drawing.Point(10, 6)
    $cbSc.Size      = New-Object System.Drawing.Size(706, 20)
    $cbSc.FlatStyle = "Flat"
    $cardSc.Controls.Add($cbSc)

    $lblDescSc = New-Object System.Windows.Forms.Label
    $lblDescSc.Text      = $scr.Desc
    $lblDescSc.Font      = $fSub
    $lblDescSc.ForeColor = $cSub
    $lblDescSc.BackColor = [System.Drawing.Color]::Transparent
    $lblDescSc.Location  = New-Object System.Drawing.Point(28, 27)
    $lblDescSc.Size      = New-Object System.Drawing.Size(688, 16)
    $cardSc.Controls.Add($lblDescSc)

    $cardSc.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 68) })
    $cardSc.Add_MouseLeave({ $this.BackColor = $cTarjeta })
    $cardSc.Add_Click({ $this.Controls[0].Checked = -not $this.Controls[0].Checked })

    $checkboxesScripts[$scr.Nombre] = $cbSc
    $ySc += 54
}

$sep = New-Object System.Windows.Forms.Panel
$sep.Size      = New-Object System.Drawing.Size(756, 1)
$sep.Location  = New-Object System.Drawing.Point(12, 558)
$sep.BackColor = $cBorde
$form.Controls.Add($sep)

$btnTodos = New-Object System.Windows.Forms.Button
$btnTodos.Text      = "Seleccionar todo"
$btnTodos.Size      = New-Object System.Drawing.Size(148, 32)
$btnTodos.Location  = New-Object System.Drawing.Point(12, 568)
$btnTodos.FlatStyle = "Flat"
$btnTodos.FlatAppearance.BorderColor = $cBorde
$btnTodos.BackColor = $cTarjeta
$btnTodos.ForeColor = $cTexto
$btnTodos.Font      = $fSub
$btnTodos.Cursor    = "Hand"
$btnTodos.Add_Click({
    foreach ($cb in $checkboxes.Values)        { $cb.Checked = $true }
    foreach ($cb in $checkboxesScripts.Values) { $cb.Checked = $true }
})
$form.Controls.Add($btnTodos)

$btnNinguno = New-Object System.Windows.Forms.Button
$btnNinguno.Text      = "Deseleccionar todo"
$btnNinguno.Size      = New-Object System.Drawing.Size(148, 32)
$btnNinguno.Location  = New-Object System.Drawing.Point(168, 568)
$btnNinguno.FlatStyle = "Flat"
$btnNinguno.FlatAppearance.BorderColor = $cBorde
$btnNinguno.BackColor = $cTarjeta
$btnNinguno.ForeColor = $cTexto
$btnNinguno.Font      = $fSub
$btnNinguno.Cursor    = "Hand"
$btnNinguno.Add_Click({
    foreach ($cb in $checkboxes.Values)        { $cb.Checked = $false }
    foreach ($cb in $checkboxesScripts.Values) { $cb.Checked = $false }
})
$form.Controls.Add($btnNinguno)

$btnInstalar = New-Object System.Windows.Forms.Button
$btnInstalar.Text      = "INSTALAR PAQUETES"
$btnInstalar.Size      = New-Object System.Drawing.Size(183, 40)
$btnInstalar.Location  = New-Object System.Drawing.Point(388, 564)
$btnInstalar.FlatStyle = "Flat"
$btnInstalar.FlatAppearance.BorderSize = 0
$btnInstalar.BackColor = [System.Drawing.Color]::FromArgb(220, 80, 0)
$btnInstalar.ForeColor = [System.Drawing.Color]::White
$btnInstalar.Font      = $fBtn
$btnInstalar.Cursor    = "Hand"
$btnInstalar.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(255, 120, 0) })
$btnInstalar.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(220, 80,  0) })
$form.Controls.Add($btnInstalar)

$btnEjecutar = New-Object System.Windows.Forms.Button
$btnEjecutar.Text      = "EJECUTAR SCRIPTS"
$btnEjecutar.Size      = New-Object System.Drawing.Size(183, 40)
$btnEjecutar.Location  = New-Object System.Drawing.Point(579, 564)
$btnEjecutar.FlatStyle = "Flat"
$btnEjecutar.FlatAppearance.BorderSize = 0
$btnEjecutar.BackColor = [System.Drawing.Color]::FromArgb(13, 148, 136)
$btnEjecutar.ForeColor = [System.Drawing.Color]::White
$btnEjecutar.Font      = $fBtn
$btnEjecutar.Cursor    = "Hand"
$btnEjecutar.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(20, 184, 166) })
$btnEjecutar.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(13, 148, 136) })
$form.Controls.Add($btnEjecutar)

$lblLogTit = New-Object System.Windows.Forms.Label
$lblLogTit.Text      = "REGISTRO"
$lblLogTit.Font      = $fCat
$lblLogTit.ForeColor = $cSub
$lblLogTit.Location  = New-Object System.Drawing.Point(12, 618)
$lblLogTit.Size      = New-Object System.Drawing.Size(300, 16)
$lblLogTit.BackColor = [System.Drawing.Color]::Transparent
$form.Controls.Add($lblLogTit)

$txtLog = New-Object System.Windows.Forms.RichTextBox
$txtLog.Location    = New-Object System.Drawing.Point(12, 636)
$txtLog.Size        = New-Object System.Drawing.Size(756, 82)
$txtLog.BackColor   = $cPanel
$txtLog.ForeColor   = $cTexto
$txtLog.Font        = $fLog
$txtLog.ReadOnly    = $true
$txtLog.BorderStyle = "None"
$txtLog.ScrollBars  = "Vertical"
$txtLog.Text        = "Listo. Selecciona paquetes o scripts y pulsa el boton correspondiente..."
$form.Controls.Add($txtLog)

function Write-Log($texto, $color = $null) {
    $txtLog.SelectionStart  = $txtLog.TextLength
    $txtLog.SelectionLength = 0
    $txtLog.SelectionColor  = if ($color) { $color } else { $cTexto }
    $txtLog.AppendText("$texto`n")
    $txtLog.ScrollToCaret()
    $form.Refresh()
}

$btnInstalar.Add_Click({
    $selList = @($checkboxes.Values | Where-Object { $_.Checked } | ForEach-Object {
        [PSCustomObject]@{ Text = $_.Text; Tag = $_.Tag }
    })
    if ($selList.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            "No has seleccionado ningun paquete.",
            "Nada que instalar",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
        return
    }
    $resp = [System.Windows.Forms.MessageBox]::Show(
        "Se instalaran $($selList.Count) paquete(s).`n`nContinuar?",
        "Confirmar instalacion",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($resp -ne "Yes") { return }

    $btnInstalar.Enabled = $false
    $btnEjecutar.Enabled = $false
    $btnTodos.Enabled    = $false
    $btnNinguno.Enabled  = $false
    $txtLog.Clear()

    # Runspace en background: la UI queda libre durante la instalacion
    $rs = [runspacefactory]::CreateRunspace()
    $rs.ApartmentState = "STA"
    $rs.ThreadOptions  = "ReuseThread"
    $rs.Open()
    $rs.SessionStateProxy.SetVariable('selList',     $selList)
    $rs.SessionStateProxy.SetVariable('txtLog',      $txtLog)
    $rs.SessionStateProxy.SetVariable('form',        $form)
    $rs.SessionStateProxy.SetVariable('btnInstalar', $btnInstalar)
    $rs.SessionStateProxy.SetVariable('btnEjecutar', $btnEjecutar)
    $rs.SessionStateProxy.SetVariable('btnTodos',    $btnTodos)
    $rs.SessionStateProxy.SetVariable('btnNinguno',  $btnNinguno)
    $rs.SessionStateProxy.SetVariable('cOK',         $cOK)
    $rs.SessionStateProxy.SetVariable('cError',      $cError)
    $rs.SessionStateProxy.SetVariable('cWarn',       $cWarn)
    $rs.SessionStateProxy.SetVariable('cSub',        $cSub)
    $rs.SessionStateProxy.SetVariable('cTexto',      $cTexto)
    $rs.SessionStateProxy.SetVariable('cBorde',      $cBorde)

    $ps = [powershell]::Create()
    $ps.Runspace = $rs
    $ps.AddScript({
        function UILog($t, $c) {
            $log = $txtLog; $txt = $t; $color = $c
            $log.Invoke([System.Windows.Forms.MethodInvoker]({
                $log.SelectionStart  = $log.TextLength
                $log.SelectionLength = 0
                $log.SelectionColor  = $color
                $log.AppendText("$txt`n")
                $log.ScrollToCaret()
            }.GetNewClosure()))
        }
        function UIEnable($v) {
            $bi = $btnInstalar; $be = $btnEjecutar; $bt = $btnTodos; $bn = $btnNinguno; $val = $v
            $form.Invoke([System.Windows.Forms.MethodInvoker]({
                $bi.Enabled = $val; $be.Enabled = $val; $bt.Enabled = $val; $bn.Enabled = $val
            }.GetNewClosure()))
        }

        UILog "Verificando Chocolatey..." $cSub
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            UILog "Instalando Chocolatey..." $cWarn
            try {
                Set-ExecutionPolicy Bypass -Scope Process -Force
                [System.Net.ServicePointManager]::SecurityProtocol = `
                    [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
                Invoke-Expression ((New-Object System.Net.WebClient).DownloadString(
                    'https://community.chocolatey.org/install.ps1'))
                $env:Path += ";$env:ALLUSERSPROFILE\chocolatey\bin"
                UILog "Chocolatey instalado correctamente." $cOK
            } catch {
                UILog "Error instalando Chocolatey: $_" $cError
                UIEnable $true
                return
            }
        } else { UILog "Chocolatey encontrado." $cOK }

        UILog "" $cTexto
        UILog "Instalando $($selList.Count) paquete(s)..." $cSub
        UILog "----------------------------------------------" $cBorde

        $ok = 0; $err = 0
        foreach ($pkg in $selList) {
            UILog "  >> $($pkg.Text)..." $cTexto
            & choco install $pkg.Tag -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) { UILog "     OK  $($pkg.Text)" $cOK;    $ok++ }
            else                     { UILog "     FALLO  $($pkg.Text)" $cError; $err++ }
        }

        UILog "----------------------------------------------" $cBorde
        if ($err -eq 0) { UILog "  Completado: $ok paquete(s) instalados sin errores." $cOK }
        else            { UILog "  Completado: $ok OK  |  $err con errores." $cWarn }
        UILog "  Puede que necesites reiniciar el equipo." $cSub
        UIEnable $true
    }) | Out-Null
    $ps.BeginInvoke() | Out-Null
})

$btnEjecutar.Add_Click({
    $selScripts = @($checkboxesScripts.Values | Where-Object { $_.Checked } | ForEach-Object {
        [PSCustomObject]@{ Nombre = $_.Tag; Accion = $scriptActions[$_.Tag] }
    })
    if ($selScripts.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            "No has seleccionado ningun script.",
            "Nada que ejecutar",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
        return
    }
    $resp = [System.Windows.Forms.MessageBox]::Show(
        "Se ejecutaran $($selScripts.Count) script(s).`n`nContinuar?",
        "Confirmar ejecucion",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($resp -ne "Yes") { return }

    $btnInstalar.Enabled = $false
    $btnEjecutar.Enabled = $false
    $btnTodos.Enabled    = $false
    $btnNinguno.Enabled  = $false
    $txtLog.Clear()

    $rs = [runspacefactory]::CreateRunspace()
    $rs.ApartmentState = "STA"
    $rs.ThreadOptions  = "ReuseThread"
    $rs.Open()
    $rs.SessionStateProxy.SetVariable('selScripts',  $selScripts)
    $rs.SessionStateProxy.SetVariable('txtLog',      $txtLog)
    $rs.SessionStateProxy.SetVariable('form',        $form)
    $rs.SessionStateProxy.SetVariable('btnInstalar', $btnInstalar)
    $rs.SessionStateProxy.SetVariable('btnEjecutar', $btnEjecutar)
    $rs.SessionStateProxy.SetVariable('btnTodos',    $btnTodos)
    $rs.SessionStateProxy.SetVariable('btnNinguno',  $btnNinguno)
    $rs.SessionStateProxy.SetVariable('cOK',         $cOK)
    $rs.SessionStateProxy.SetVariable('cError',      $cError)
    $rs.SessionStateProxy.SetVariable('cWarn',       $cWarn)
    $rs.SessionStateProxy.SetVariable('cSub',        $cSub)
    $rs.SessionStateProxy.SetVariable('cTexto',      $cTexto)
    $rs.SessionStateProxy.SetVariable('cBorde',      $cBorde)

    $ps = [powershell]::Create()
    $ps.Runspace = $rs
    $ps.AddScript({
        function UILog($t, $c) {
            $log = $txtLog; $txt = $t; $color = $c
            $log.Invoke([System.Windows.Forms.MethodInvoker]({
                $log.SelectionStart  = $log.TextLength
                $log.SelectionLength = 0
                $log.SelectionColor  = $color
                $log.AppendText("$txt`n")
                $log.ScrollToCaret()
            }.GetNewClosure()))
        }
        function UIEnable($v) {
            $bi = $btnInstalar; $be = $btnEjecutar; $bt = $btnTodos; $bn = $btnNinguno; $val = $v
            $form.Invoke([System.Windows.Forms.MethodInvoker]({
                $bi.Enabled = $val; $be.Enabled = $val; $bt.Enabled = $val; $bn.Enabled = $val
            }.GetNewClosure()))
        }

        UILog "Ejecutando $($selScripts.Count) script(s)..." $cSub
        UILog "----------------------------------------------" $cBorde

        $ok = 0; $err = 0
        foreach ($s in $selScripts) {
            UILog "  >> $($s.Nombre)..." $cTexto
            try {
                & ([scriptblock]::Create($s.Accion))
                UILog "     OK  $($s.Nombre)" $cOK
                $ok++
            } catch {
                UILog "     FALLO  $($s.Nombre): $_" $cError
                $err++
            }
        }

        UILog "----------------------------------------------" $cBorde
        if ($err -eq 0) { UILog "  Completado: $ok script(s) ejecutados sin errores." $cOK }
        else            { UILog "  Completado: $ok OK  |  $err con errores." $cWarn }
        UIEnable $true
    }) | Out-Null
    $ps.BeginInvoke() | Out-Null
})

$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
