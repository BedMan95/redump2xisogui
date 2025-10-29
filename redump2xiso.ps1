Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ---------- Config ----------
$configPath  = "config.json"

function Save-Config {
    param([string]$Path)
    @{ xdvdfsPath = $Path } | ConvertTo-Json | Out-File -FilePath $configPath -Encoding UTF8
}

function Load-Config {
    if (Test-Path $configPath) {
        try { (Get-Content $configPath -Raw | ConvertFrom-Json).xdvdfsPath }
        catch { $null }
    } else { $null }
}

$global:xdvdfsPath = $null

# ---------- Form (with ICON) ----------
$form = New-Object System.Windows.Forms.Form
$form.Text          = "Xbox Redump to XISO"
$form.Size          = New-Object System.Drawing.Size(720, 540)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox   = $false

# === TAMBAHKAN IKON ===
$iconPath = "Redump2XISO.ico"
if (Test-Path $iconPath) {
    try {
        $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
    } catch { }
} else {
    Add-Log "Icon not found: Redump2XISO.ico" ([System.Drawing.Color]::Orange)
}

# ---------- Title ----------
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text   = "Xbox Redump ISO to XISO"
$lblTitle.Location = New-Object System.Drawing.Point(20, 15)
$lblTitle.AutoSize = $true
$lblTitle.Font   = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($lblTitle)

# ---------- xdvdfs.exe ----------
$lblXdvdfs = New-Object System.Windows.Forms.Label
$lblXdvdfs.Text = "xdvdfs.exe:"
$lblXdvdfs.Location = New-Object System.Drawing.Point(20, 55)
$lblXdvdfs.Size = New-Object System.Drawing.Size(80, 23)
$form.Controls.Add($lblXdvdfs)

$txtXdvdfs = New-Object System.Windows.Forms.TextBox
$txtXdvdfs.Location = New-Object System.Drawing.Point(100, 55)
$txtXdvdfs.Size     = New-Object System.Drawing.Size(480, 23)
$txtXdvdfs.ReadOnly = $true
$form.Controls.Add($txtXdvdfs)

$btnSetXdvdfs = New-Object System.Windows.Forms.Button
$btnSetXdvdfs.Location = New-Object System.Drawing.Point(590, 53)
$btnSetXdvdfs.Size     = New-Object System.Drawing.Size(90, 27)
$btnSetXdvdfs.Text     = "Browse..."
$form.Controls.Add($btnSetXdvdfs)

# ---------- Input ISO ----------
$lblIso = New-Object System.Windows.Forms.Label
$lblIso.Text = "Input ISO:"
$lblIso.Location = New-Object System.Drawing.Point(20, 95)
$lblIso.Size = New-Object System.Drawing.Size(80, 23)
$form.Controls.Add($lblIso)

$txtIso = New-Object System.Windows.Forms.TextBox
$txtIso.Location = New-Object System.Drawing.Point(100, 95)
$txtIso.Size     = New-Object System.Drawing.Size(480, 23)
$txtIso.ReadOnly = $true
$form.Controls.Add($txtIso)

$btnBrowseIso = New-Object System.Windows.Forms.Button
$btnBrowseIso.Location = New-Object System.Drawing.Point(590, 93)
$btnBrowseIso.Size     = New-Object System.Drawing.Size(90, 27)
$btnBrowseIso.Text     = "Browse..."
$form.Controls.Add($btnBrowseIso)

# ---------- Output XISO ----------
$lblOutput = New-Object System.Windows.Forms.Label
$lblOutput.Text = "Output XISO:"
$lblOutput.Location = New-Object System.Drawing.Point(20, 135)
$lblOutput.Size = New-Object System.Drawing.Size(80, 23)
$form.Controls.Add($lblOutput)

$txtOutput = New-Object System.Windows.Forms.TextBox
$txtOutput.Location = New-Object System.Drawing.Point(100, 135)
$txtOutput.Size     = New-Object System.Drawing.Size(480, 23)
$txtOutput.ReadOnly = $true
$form.Controls.Add($txtOutput)

$btnBrowseOutput = New-Object System.Windows.Forms.Button
$btnBrowseOutput.Location = New-Object System.Drawing.Point(590, 133)
$btnBrowseOutput.Size     = New-Object System.Drawing.Size(90, 27)
$btnBrowseOutput.Text     = "Browse..."
$form.Controls.Add($btnBrowseOutput)

# ---------- PACK Button ----------
$btnPack = New-Object System.Windows.Forms.Button
$btnPack.Location = New-Object System.Drawing.Point(20, 170)
$btnPack.Size     = New-Object System.Drawing.Size(660, 45)
$btnPack.Text     = "PACK TO XISO"
$btnPack.Enabled  = $false
$btnPack.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnPack.ForeColor = [System.Drawing.Color]::White
$btnPack.Font     = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnPack)

# ---------- LOG (RichTextBox) ----------
$lblLog = New-Object System.Windows.Forms.Label
$lblLog.Text = "Log:"
$lblLog.Location = New-Object System.Drawing.Point(20, 230)
$lblLog.AutoSize = $true
$lblLog.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($lblLog)

$rtbLog = New-Object System.Windows.Forms.RichTextBox
$rtbLog.Location = New-Object System.Drawing.Point(20, 250)
$rtbLog.Size     = New-Object System.Drawing.Size(660, 250)
$rtbLog.ReadOnly = $true
$rtbLog.Font     = New-Object System.Drawing.Font("Consolas", 9)
$rtbLog.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$rtbLog.ForeColor = [System.Drawing.Color]::LightGray
$form.Controls.Add($rtbLog)

# ---------- Log Function (DD/MM/YYYY HH:mm:ss) ----------
function Add-Log {
    param(
        [string]$Text,
        [System.Drawing.Color]$Color = [System.Drawing.Color]::LightGray
    )
    $ts = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
    $line = "[$ts] $Text`r`n"
    $rtbLog.SelectionStart  = $rtbLog.TextLength
    $rtbLog.SelectionLength = 0
    $rtbLog.SelectionColor  = $Color
    $rtbLog.AppendText($line)
    $rtbLog.SelectionColor  = $rtbLog.ForeColor
    $rtbLog.ScrollToCaret()
    $form.Refresh()
}

# ---------- Event: Select xdvdfs.exe ----------
$btnSetXdvdfs.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Filter = "Executable (*.exe)|*.exe"
    $dlg.Title  = "Select xdvdfs.exe"
    $dlg.FileName = "xdvdfs.exe"
    if ($dlg.ShowDialog() -eq "OK") {
        $global:xdvdfsPath = $dlg.FileName
        $txtXdvdfs.Text = $dlg.FileName
        Save-Config -Path $global:xdvdfsPath
        Add-Log "xdvdfs.exe: $($dlg.SafeFileName)" ([System.Drawing.Color]::LimeGreen)
        Update-PackButton
    }
})

# ---------- Event: Select Input ISO ----------
$btnBrowseIso.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Filter = "ISO Files (*.iso)|*.iso"
    $dlg.Title  = "Select Redump ISO File"
    if ($dlg.ShowDialog() -eq "OK") {
        $txtIso.Text = $dlg.FileName
        $suggest = [System.IO.Path]::ChangeExtension($dlg.FileName, "xiso.iso")
        $txtOutput.Text = $suggest
        Add-Log "Input: $($dlg.SafeFileName)" ([System.Drawing.Color]::Cyan)
        Update-PackButton
    }
})

# ---------- Event: Select Output ----------
$btnBrowseOutput.Add_Click({
    $dlg = New-Object System.Windows.Forms.SaveFileDialog
    $dlg.Filter = "XISO Files (*.iso)|*.iso"
    $dlg.Title  = "Select Output XISO File"
    $dlg.FileName = [System.IO.Path]::GetFileName($txtOutput.Text)
    if ($dlg.ShowDialog() -eq "OK") {
        $txtOutput.Text = $dlg.FileName
        Add-Log "Output: $([System.IO.Path]::GetFileName($dlg.FileName))" ([System.Drawing.Color]::Yellow)
        Update-PackButton
    }
})

# ---------- Update PACK Button ----------
function Update-PackButton {
    $okX = $global:xdvdfsPath -and (Test-Path $global:xdvdfsPath)
    $okI = $txtIso.Text -and (Test-Path $txtIso.Text)
    $btnPack.Enabled = ($okX -and $okI)
}

# ---------- Event: PACK ----------
$btnPack.Add_Click({
    $isoPath = $txtIso.Text
    $outputPath = $txtOutput.Text.Trim()

    if (-not (Test-Path $isoPath)) {
        Add-Log "ERROR: Input ISO file not found!" ([System.Drawing.Color]::Red)
        return
    }

    # Lock UI
    $btnPack.Enabled = $false
    $btnBrowseIso.Enabled = $false
    $btnSetXdvdfs.Enabled = $false
    $btnBrowseOutput.Enabled = $false

    $command = "pack `"$isoPath`""
    if ($outputPath) { $command += " `"$outputPath`"" }
    Add-Log "Running: xdvdfs.exe $command" ([System.Drawing.Color]::Yellow)

    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $global:xdvdfsPath
        $psi.Arguments = $command
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.CreateNoWindow = $true

        $proc = [System.Diagnostics.Process]::Start($psi)

        # Real-time stdout
        while (-not $proc.StandardOutput.EndOfStream) {
            $line = $proc.StandardOutput.ReadLine()
            if ($line) { Add-Log $line ([System.Drawing.Color]::White) }
        }

        # Real-time stderr
        while (-not $proc.StandardError.EndOfStream) {
            $line = $proc.StandardError.ReadLine()
            if ($line) { Add-Log "ERROR: $line" ([System.Drawing.Color]::Red) }
        }

        $proc.WaitForExit()

        if ($proc.ExitCode -eq 0) {
            $outMsg = if ($outputPath) { "Output: $outputPath" } else { "Output: Auto-generated" }
            Add-Log "SUCCESS! $outMsg" ([System.Drawing.Color]::LimeGreen)
            [System.Windows.Forms.MessageBox]::Show(
                "Process completed successfully!`n$outMsg",
                "Success", "OK", "Information")
        } else {
            Add-Log "FAILED! Exit code: $($proc.ExitCode)" ([System.Drawing.Color]::Red)
        }
    }
    catch {
        Add-Log "EXCEPTION: $($_.Exception.Message)" ([System.Drawing.Color]::Red)
    }
    finally {
        $btnPack.Enabled = $true
        $btnBrowseIso.Enabled = $true
        $btnSetXdvdfs.Enabled = $true
        $btnBrowseOutput.Enabled = $true
        Update-PackButton
    }
})

# ---------- Startup: Load config ----------
$loaded = Load-Config
if ($loaded -and (Test-Path $loaded)) {
    $global:xdvdfsPath = $loaded
    $txtXdvdfs.Text = $loaded
    Add-Log "Config loaded: $($loaded | Split-Path -Leaf)" ([System.Drawing.Color]::LimeGreen)
} else {
    Add-Log "Please select xdvdfs.exe first." ([System.Drawing.Color]::Orange)
}

Update-PackButton

# ---------- Show Form ----------
[void]$form.ShowDialog()
