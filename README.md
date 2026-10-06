# iq-agent-cheri

**English** · [Español](#español)

A terminal agent (PowerShell) that runs the cognitive-evaluation prompt in `prompt_sistema.md` against the Claude API (`claude-opus-5-5`). The evaluation itself is in Spanish.

## Usage

```powershell
$env:ANTHROPIC_API_KEY = "sk-ant-..."   # or: ant auth login
.\agente.ps1
```

- `/salir` pauses and saves; running `.\agente.ps1` again resumes.
- `-Nueva` starts over (the previous session is backed up).
- `-Sesion name` keeps separate evaluations.
- `-Esfuerzo low|medium|high|xhigh|max` (default `high`).

If PowerShell blocks the script: `powershell -ExecutionPolicy Bypass -File .\agente.ps1`

## What the script adds on top of the chat

- **Hidden log**: the evaluator scores inside `<registro>`; it's never shown, but it's saved so it survives between sessions.
- **Working memory**: stimuli inside `<memoria segundos="N">` are shown for N seconds, then the screen and scrollback are wiped.
- **Timing**: each answer silently carries how long you took to send it.

## Don't contaminate the test

`sesiones\*.json` (git-ignored) holds the correct answers and the evaluator's log. Don't open it until you're done.

---

## Español

Agente de terminal (PowerShell) que corre el prompt de evaluación cognitiva de `prompt_sistema.md` contra la API de Claude (`claude-opus-5-5`).

### Uso

```powershell
$env:ANTHROPIC_API_KEY = "sk-ant-..."   # o bien: ant auth login
.\agente.ps1
```

- `/salir` pausa y guarda; al volver a ejecutar `.\agente.ps1` se retoma.
- `-Nueva` empieza de cero (la sesión anterior se respalda).
- `-Sesion nombre` lleva evaluaciones separadas.
- `-Esfuerzo low|medium|high|xhigh|max` (por defecto `high`).

Si PowerShell bloquea el script: `powershell -ExecutionPolicy Bypass -File .\agente.ps1`

### Qué agrega el script además del chat

- **Registro oculto**: el evaluador puntúa dentro de `<registro>`; no se muestra, pero se guarda para sobrevivir entre sesiones.
- **Memoria de trabajo**: los estímulos en `<memoria segundos="N">` se muestran N segundos y luego se borra la pantalla y el scroll.
- **Tiempos**: cada respuesta lleva adjunto, sin que lo veas, cuánto tardaste en enviarla.

### Para no contaminar la prueba

`sesiones\*.json` (ignorado por git) contiene las respuestas correctas y el registro del evaluador. No lo abras hasta terminar.
