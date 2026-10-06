<#
.SYNOPSIS
    Conversational cognitive-evaluation agent for the terminal.

.DESCRIPTION
    Runs the prompt in prompt_sistema.md as an interactive chat through the Claude Code
    CLI (`claude -p`), so it uses your Claude subscription instead of the paid API.
    Each turn resumes the same Claude Code session; its id is kept in
    sesiones\<Sesion>.json so the evaluation can span several sittings.
    Type /salir to pause.

.EXAMPLE
    .\agente.ps1                 # start, or resume the "evaluacion" session
    .\agente.ps1 -Nueva          # start over (the old session is backed up)
    .\agente.ps1 -Sesion otra    # keep a separate evaluation
#>
[CmdletBinding()]
param(
    [string]$Sesion = "evaluacion",
    [switch]$Nueva,
    [string]$Modelo = "sonnet",
    [ValidateSet("low", "medium", "high", "xhigh", "max")]
    [string]$Esfuerzo = "high"
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [Text.Encoding]::UTF8
[Console]::InputEncoding = [Text.Encoding]::UTF8
# Text piped into `claude` is encoded with $OutputEncoding (ASCII by default in 5.1).
$OutputEncoding = New-Object Text.UTF8Encoding($false)

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "No se encontró Claude Code ('claude'). Instálalo y ejecuta 'claude' una vez para iniciar sesión." -ForegroundColor Red
    exit 1
}

$esc = [char]27
$stateDir = Join-Path $PSScriptRoot "sesiones"
$statePath = Join-Path $stateDir "$Sesion.json"
$promptPath = Join-Path $PSScriptRoot "prompt_sistema.md"
if (-not (Test-Path $stateDir)) { New-Item -ItemType Directory $stateDir | Out-Null }

function Invoke-Claude([string]$text, [string]$sessionFlag) {
    # --safe-mode keeps CLAUDE.md, memory, plugins and MCP out of the evaluation;
    # --tools '""' leaves the evaluator with no tools at all.
    $cliArgs = @(
        "-p", "--output-format", "json",
        "--safe-mode", "--tools", '""',
        "--system-prompt-file", $promptPath,
        "--model", $Modelo, "--effort", $Esfuerzo,
        $sessionFlag, $script:sessionId
    )
    # Sessions are stored per working directory, so always run from sesiones\.
    Push-Location $stateDir
    try { $raw = ($text | & claude @cliArgs) -join "`n" }
    finally { Pop-Location }
    try { return $raw | ConvertFrom-Json }
    catch { return [pscustomobject]@{ is_error = $true; result = $raw } }
}

function Show-Reply([string]$text) {
    # <registro> is the evaluator's hidden scoring log: kept in the session, never shown.
    $text = [regex]::Replace($text, '(?s)<registro>.*?</registro>', '').Trim()
    $m = [regex]::Match($text, '(?s)<memoria(?:\s+segundos="(\d+)")?\s*>(.*?)</memoria>')
    if (-not $m.Success) {
        Write-Host "`n$text`n" -ForegroundColor Cyan
        return
    }
    $before = $text.Substring(0, $m.Index).Trim()
    $after = $text.Substring($m.Index + $m.Length).Trim()
    $seconds = if ($m.Groups[1].Success) { [int]$m.Groups[1].Value } else { 5 }

    if ($before) { Write-Host "`n$before`n" -ForegroundColor Cyan }
    Read-Host "Pulsa Enter para ver el estímulo ($seconds s)" | Out-Null
    Write-Host "`n    $($m.Groups[2].Value.Trim())`n" -ForegroundColor Yellow
    for ($s = $seconds; $s -gt 0; $s--) {
        Write-Host -NoNewline "`r  se oculta en $s s " -ForegroundColor DarkGray
        Start-Sleep -Seconds 1
    }
    # Wipe the screen and the scrollback so the stimulus can't be scrolled back to.
    Write-Host -NoNewline "$esc[3J"
    Clear-Host
    Write-Host "(estímulo oculto)`n" -ForegroundColor DarkGray
    if ($after) { Write-Host "$after`n" -ForegroundColor Cyan }
}

function Send-Turn([string]$userText) {
    Write-Host "  ..." -ForegroundColor DarkGray
    # The first turn creates the session under our id; later turns resume it.
    $flag = if ($script:started) { "--resume" } else { "--session-id" }
    $resp = Invoke-Claude $userText $flag
    if ($resp.is_error) {
        Write-Host "Claude Code devolvió un error: $($resp.result)" -ForegroundColor Red
        return $false
    }
    if (-not $script:started) {
        $script:started = $true
        $state = [ordered]@{ session_id = $script:sessionId; creada = (Get-Date).ToString("s") }
        [IO.File]::WriteAllText($statePath, (ConvertTo-Json $state), (New-Object Text.UTF8Encoding($false)))
    }
    Show-Reply $resp.result
    if ($resp.stop_reason -eq "max_tokens") {
        Write-Host "(La respuesta se cortó por longitud; escribe 'continúa'.)" -ForegroundColor DarkYellow
    }
    return $true
}

# --- Session start --------------------------------------------------------------
if ($Nueva -and (Test-Path $statePath)) {
    $backup = $statePath -replace '\.json$', ("-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".json")
    Move-Item $statePath $backup
    Write-Host "Sesión anterior respaldada en $backup" -ForegroundColor DarkGray
}

$today = Get-Date -Format "yyyy-MM-dd HH:mm"
if (Test-Path $statePath) {
    $script:sessionId = ([IO.File]::ReadAllText($statePath, [Text.Encoding]::UTF8) | ConvertFrom-Json).session_id
    $script:started = $true
    $opening = "[Sistema: el evaluado retoma la evaluación tras una pausa ($today). Continúa donde quedó según tu registro, sin repetir tareas ya vistas.]"
    Write-Host "Retomando la sesión '$Sesion'." -ForegroundColor DarkGray
}
else {
    $script:sessionId = [guid]::NewGuid().ToString()
    $script:started = $false
    $opening = "[Sistema: inicio de la evaluación ($today).] Comenzar."
}

Write-Host "Evaluación cognitiva conversacional - escribe /salir para pausar y guardar." -ForegroundColor DarkGray
if (-not (Send-Turn $opening)) { exit 1 }

while ($true) {
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $answer = Read-Host "Tú"
    $timer.Stop()
    if ($answer -match '^\s*/(salir|pausa)\s*$') {
        Write-Host "Progreso guardado. Retoma con .\agente.ps1" -ForegroundColor DarkGray
        break
    }
    if (-not $answer.Trim()) { continue }
    $meta = "[metadatos: tiempo de respuesta {0:N1} s]" -f $timer.Elapsed.TotalSeconds
    if (-not (Send-Turn "$meta`n$answer")) {
        Write-Host "Vuelve a enviar tu respuesta (o escribe /salir y retoma más tarde)." -ForegroundColor DarkYellow
    }
}
