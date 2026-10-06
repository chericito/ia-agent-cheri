# ia-agent-cheri

**English** · [Español](#español)

A terminal agent (PowerShell) that runs a conversational cognitive evaluation with Claude. It runs on your **Claude subscription** through Claude Code, so there's no API key and no per-use charge. The evaluation itself is in Spanish. The full evaluator prompt is in `prompt_sistema.md`.

> This is an experimental, conversational estimate — not a clinical IQ test.

## Quick start (step by step)

### 1. Install Claude Code and sign in (one time)

You need a Claude subscription (Pro or Max).

1. Open **PowerShell** (press the Windows key, type `PowerShell`, press Enter).
2. Install Claude Code:

   ```powershell
   irm https://claude.ai/install.ps1 | iex
   ```

3. Close PowerShell, open it again, and run `claude`. Choose to sign in with your Claude account, finish the login in the browser, then type `/exit`.

To check it's ready:

```powershell
claude auth status
```

It should show `"loggedIn": true` and your `subscriptionType`.

### 2. Download the agent

```powershell
cd $HOME
git clone https://github.com/chericito/ia-agent-cheri.git
cd ia-agent-cheri
```

No git? On the GitHub page click **Code → Download ZIP**, unzip it, then `cd` into the folder in PowerShell.

### 3. Allow PowerShell to run the script (one time)

Windows blocks scripts by default. Allow scripts for your user only:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

If you downloaded the ZIP instead of using git, also unblock the file:

```powershell
Unblock-File .\agente.ps1
```

### 4. Start the evaluation

From the `ia-agent-cheri` folder:

```powershell
.\agente.ps1
```

## During the evaluation

- Type your answer and press **Enter**. You can answer "no sé" (I don't know).
- Each reply takes a few seconds while Claude thinks (you'll see `...`).
- When a **memory task** appears, press Enter to see the stimulus. It disappears after a few seconds and the screen is cleared — that's intentional.
- Your response time is recorded automatically. Take the time you need.
- Type **`/salir`** at any moment to pause. Progress is saved after every answer.

## Next sessions

| What you want | Command |
|---|---|
| Continue where you left off | `.\agente.ps1` |
| Start over from scratch (old session is backed up) | `.\agente.ps1 -Nueva` |
| Run a separate evaluation (e.g. for another person) | `.\agente.ps1 -Sesion maria` |
| Use less of your plan's usage (less thorough evaluator) | `.\agente.ps1 -Esfuerzo medium` |

Remember to `cd` into the `ia-agent-cheri` folder first.

## Model and usage limits

- The agent uses **Sonnet** by default, the model Claude Code uses on the Pro plan. On Max you can try `.\agente.ps1 -Modelo opus`.
- Everything counts against your subscription's usage limits. A long session can hit the limit; if that happens, type `/salir` and resume when it resets. Nothing is lost.

## Troubleshooting

| Message | Fix |
|---|---|
| `running scripts is disabled on this system` | Do step 3, or run once with `powershell -ExecutionPolicy Bypass -File .\agente.ps1` |
| `No se encontró Claude Code` | Do step 1, then reopen PowerShell |
| `Claude Code devolvió un error` mentioning login | Run `claude`, sign in again, then `/exit` |
| `Claude Code devolvió un error` mentioning a usage limit | Type `/salir` and resume after the limit resets |
| Accents look broken (`Ã³`) | Use **Windows Terminal** instead of the old blue PowerShell window |

## Don't contaminate the test

The evaluator's hidden notes, including the correct answers, live in the Claude Code session history. Don't open past sessions with `claude --resume` from the `sesiones` folder until you're done.

## How it works

- **Claude Code backend**: each answer runs `claude -p` and resumes the same session (its id is in `sesiones\<name>.json`, which git ignores). `--safe-mode` and no tools keep your other projects, memory and settings out of the evaluation.
- **Hidden log**: the evaluator scores inside `<registro>` tags; the script never shows them, but they stay in the session so the evaluator remembers between sittings.
- **Working memory**: stimuli inside `<memoria segundos="N">` are shown for N seconds, then the screen and scrollback are wiped.
- **Timing**: each answer silently carries how long you took to send it.

---

## Español

Agente de terminal (PowerShell) que hace una evaluación cognitiva conversacional con Claude. Funciona con tu **suscripción de Claude** a través de Claude Code: no necesita API key ni cobra por uso. El prompt completo del evaluador está en `prompt_sistema.md`.

> Es una estimación experimental y conversacional, no una prueba clínica de IQ.

### Inicio rápido (paso a paso)

#### 1. Instala Claude Code e inicia sesión (una sola vez)

Necesitas una suscripción de Claude (Pro o Max).

1. Abre **PowerShell** (tecla Windows, escribe `PowerShell`, Enter).
2. Instala Claude Code:

   ```powershell
   irm https://claude.ai/install.ps1 | iex
   ```

3. Cierra PowerShell, ábrelo de nuevo y ejecuta `claude`. Elige iniciar sesión con tu cuenta de Claude, termina el login en el navegador y luego escribe `/exit`.

Para comprobar que está listo:

```powershell
claude auth status
```

Debe mostrar `"loggedIn": true` y tu `subscriptionType`.

#### 2. Descarga el agente

```powershell
cd $HOME
git clone https://github.com/chericito/ia-agent-cheri.git
cd ia-agent-cheri
```

¿No tienes git? En la página de GitHub haz clic en **Code → Download ZIP**, descomprímelo y entra a la carpeta con `cd` en PowerShell.

#### 3. Permite que PowerShell ejecute el script (una sola vez)

Windows bloquea los scripts por defecto. Permítelos solo para tu usuario:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

Si descargaste el ZIP en vez de usar git, desbloquea también el archivo:

```powershell
Unblock-File .\agente.ps1
```

#### 4. Empieza la evaluación

Desde la carpeta `ia-agent-cheri`:

```powershell
.\agente.ps1
```

### Durante la evaluación

- Escribe tu respuesta y pulsa **Enter**. Puedes responder "no sé".
- Cada respuesta tarda unos segundos mientras Claude piensa (verás `...`).
- Cuando aparezca una **tarea de memoria**, pulsa Enter para ver el estímulo. Desaparece a los pocos segundos y se borra la pantalla: es a propósito.
- Tu tiempo de respuesta se registra solo. Tómate el tiempo que necesites.
- Escribe **`/salir`** en cualquier momento para pausar. El progreso se guarda después de cada respuesta.

### Siguientes sesiones

| Qué quieres | Comando |
|---|---|
| Seguir donde lo dejaste | `.\agente.ps1` |
| Empezar de cero (la sesión anterior se respalda) | `.\agente.ps1 -Nueva` |
| Llevar otra evaluación aparte (p. ej. de otra persona) | `.\agente.ps1 -Sesion maria` |
| Gastar menos del uso de tu plan (evaluador menos exhaustivo) | `.\agente.ps1 -Esfuerzo medium` |

Recuerda entrar primero a la carpeta `ia-agent-cheri` con `cd`.

### Modelo y límites de uso

- El agente usa **Sonnet** por defecto, el modelo que usa Claude Code en el plan Pro. Con Max puedes probar `.\agente.ps1 -Modelo opus`.
- Todo cuenta contra los límites de uso de tu suscripción. Una sesión larga puede llegar al límite; si pasa, escribe `/salir` y retoma cuando se renueve. No se pierde nada.

### Solución de problemas

| Mensaje | Solución |
|---|---|
| `running scripts is disabled on this system` | Haz el paso 3, o ejecútalo una vez con `powershell -ExecutionPolicy Bypass -File .\agente.ps1` |
| `No se encontró Claude Code` | Haz el paso 1 y vuelve a abrir PowerShell |
| `Claude Code devolvió un error` que menciona el login | Ejecuta `claude`, vuelve a iniciar sesión y luego `/exit` |
| `Claude Code devolvió un error` que menciona un límite de uso | Escribe `/salir` y retoma cuando se renueve el límite |
| Los acentos se ven mal (`Ã³`) | Usa **Windows Terminal** en vez de la ventana azul antigua de PowerShell |

### Para no contaminar la prueba

Las notas ocultas del evaluador, incluidas las respuestas correctas, quedan en el historial de sesiones de Claude Code. No abras sesiones pasadas con `claude --resume` desde la carpeta `sesiones` hasta terminar.

### Cómo funciona

- **Claude Code por debajo**: cada respuesta ejecuta `claude -p` y retoma la misma sesión (su id está en `sesiones\<nombre>.json`, que git ignora). `--safe-mode` y la ausencia de herramientas dejan fuera de la evaluación tus otros proyectos, tu memoria y tu configuración.
- **Registro oculto**: el evaluador puntúa dentro de etiquetas `<registro>`; el script nunca las muestra, pero quedan en la sesión para que el evaluador recuerde entre sesiones.
- **Memoria de trabajo**: los estímulos en `<memoria segundos="N">` se muestran N segundos y luego se borra la pantalla y el scroll.
- **Tiempos**: cada respuesta lleva adjunto, sin que lo veas, cuánto tardaste en enviarla.
