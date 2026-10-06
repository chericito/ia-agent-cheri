<#
.SYNOPSIS
    Conversational cognitive-evaluation agent (Claude API) for the terminal.

.DESCRIPTION
    Runs the prompt in prompt_sistema.md as an interactive chat. Progress is saved
    after every turn to sesiones\<Sesion>.json, so the evaluation can span several
    sessions. Type /salir to pause.

.EXAMPLE
    .\agente.ps1                 # start, or resume the "evaluacion" session
    .\agente.ps1 -Nueva          # start over (the old session is backed up)
    .\agente.ps1 -Sesion otra    # keep a separate evaluation
#>
[CmdletBinding()]
param(
    [string]$Sesion = "evaluacion",
    [switch]$Nueva,
    [string]$Modelo = "claude-opus-5-5",
    [ValidateSet("low", "medium", "high", "xhigh", "max")]
    [string]$Esfuerzo = "high"
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [Text.Encoding]::UTF8
[Console]::InputEncoding = [Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$esc = [char]27
$stateDir = Join-Path $PSScriptRoot "sesiones"
$statePath = Join-Path $stateDir "$Sesion.json"
$system = [IO.File]::ReadAllText((Join-Path $PSScriptRoot "prompt_sistema.md"), [Text.Encoding]::UTF8)
$messages = New-Object System.Collections.ArrayList

function Get-ApiHeaders {
    $betas = @("server-side-fallback-2026-07-01")
    $h = @{ "anthropic-version" = "2023-06-01" }
    if ($env:ANTHROPIC_API_KEY) {
        $h["x-api-key"] = $env:ANTHROPIC_API_KEY
    }
    elseif (Get-Command ant -ErrorAction SilentlyContinue) {
        # Short-lived OAuth token from an `ant auth login` profile.
        $h["authorization"] = "Bearer " + (& ant auth print-credentials --access-token).Trim()
        $betas += "oauth-2025-04-20"
    }
    else {
        throw "No hay credenciales: define `$env:ANTHROPIC_API_KEY o inicia sesión con 'ant auth login'."
    }
    $h["anthropic-beta"] = $betas -join ","
    $h
}

function Invoke-Claude {
    $body = [ordered]@{
        model         = $Modelo
        max_tokens    = 16000
        system        = $system
        messages      = $messages.ToArray()
        output_config = @{ effort = $Esfuerzo }
        cache_control = @{ type = "ephemeral" }
        fallbacks     = "default"
    }
    $bytes = [Text.Encoding]::UTF8.GetBytes((ConvertTo-Json -InputObject $body -Depth 64 -Compress))

    for ($attempt = 1; ; $attempt++) {
        $headers = Get-ApiHeaders
        try {
            $r = Invoke-WebRequest -Uri "https://api.anthropic.com/v1/messages" -Method Post `
                -Headers $headers -ContentType "application/json; charset=utf-8" -Body $bytes `
                -UseBasicParsing -TimeoutSec 600
            # Decode explicitly: PowerShell 5.1 guesses the charset wrong for JSON.
            return [Text.Encoding]::UTF8.GetString($r.RawContentStream.ToArray()) | ConvertFrom-Json
        }
        catch {
            $status = 0
            $detail = $_.Exception.Message
            if ($_.Exception.Response) {
                $status = [int]$_.Exception.Response.StatusCode
                try {
                    $reader = New-Object IO.StreamReader($_.Exception.Response.GetResponseStream(), [Text.Encoding]::UTF8)
                    $detail = $reader.ReadToEnd()
                }
                catch {}
            }
            $retryable = $status -eq 0 -or $status -eq 408 -or $status -eq 429 -or $status -ge 500
            if (-not $retryable -or $attempt -ge 4) { throw "Error de la API ($status): $detail" }
            $wait = 5 * $attempt
            Write-Host "  (reintentando en $wait s; estado $status)" -ForegroundColor DarkGray
            Start-Sleep -Seconds $wait
        }
    }
}

function Save-State {
    if (-not (Test-Path $stateDir)) { New-Item -ItemType Directory $stateDir | Out-Null }
    $state = [ordered]@{
        modelo      = $Modelo
        actualizado = (Get-Date).ToString("s")
        messages    = $messages.ToArray()
    }
    [IO.File]::WriteAllText($statePath, (ConvertTo-Json -InputObject $state -Depth 64), (New-Object Text.UTF8Encoding($false)))
}

function Show-Reply([string]$text) {
    # <registro> is the evaluator's hidden scoring log: kept in history, never shown.
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
    [void]$messages.Add(@{ role = "user"; content = $userText })
    Write-Host "  ..." -ForegroundColor DarkGray
    try {
        $resp = Invoke-Claude
    }
    catch {
        $messages.RemoveAt($messages.Count - 1)
        Write-Host "$_" -ForegroundColor Red
        return $false
    }
    if ($resp.stop_reason -eq "refusal") {
        $messages.RemoveAt($messages.Count - 1)
        Write-Host "El modelo declinó responder a ese mensaje. Reformúlalo." -ForegroundColor Red
        return $false
    }
    # Keep the full content (thinking blocks included): they must be sent back unchanged.
    [void]$messages.Add(@{ role = "assistant"; content = @($resp.content) })
    Save-State
    $text = (@($resp.content) | Where-Object { $_.type -eq "text" } | ForEach-Object { $_.text }) -join "`n"
    Show-Reply $text
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
    $saved = [IO.File]::ReadAllText($statePath, [Text.Encoding]::UTF8) | ConvertFrom-Json
    foreach ($msg in $saved.messages) { [void]$messages.Add($msg) }
    $opening = "[Sistema: el evaluado retoma la evaluación tras una pausa ($today). Continúa donde quedó según tu registro, sin repetir tareas ya vistas.]"
    Write-Host "Retomando la sesión '$Sesion' ($($messages.Count) mensajes)." -ForegroundColor DarkGray
}
else {
    $opening = "[Sistema: inicio de la evaluación ($today).] Comenzar."
}

Write-Host "Evaluación cognitiva conversacional - escribe /salir para pausar y guardar." -ForegroundColor DarkGray
if (-not (Send-Turn $opening)) { exit 1 }

while ($true) {
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $answer = Read-Host "Tú"
    $timer.Stop()
    if ($answer -match '^\s*/(salir|pausa)\s*$') {
        Write-Host "Progreso guardado en $statePath. Retoma con .\agente.ps1" -ForegroundColor DarkGray
        break
    }
    if (-not $answer.Trim()) { continue }
    $meta = "[metadatos: tiempo de respuesta {0:N1} s]" -f $timer.Elapsed.TotalSeconds
    if (-not (Send-Turn "$meta`n$answer")) {
        Write-Host "No se registró ese mensaje; vuelve a enviarlo." -ForegroundColor DarkYellow
    }
}
