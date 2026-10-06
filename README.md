# ia-agent-cheri

**English** · [Español](#español)

A terminal agent (PowerShell) that runs a conversational cognitive evaluation using the Claude API (`claude-opus-5-5`). The evaluation itself is in Spanish. The full evaluator prompt is in `prompt_sistema.md`.

> This is an experimental, conversational estimate — not a clinical IQ test.

## Quick start (step by step)

### 1. Get an Anthropic API key

1. Go to [console.anthropic.com](https://console.anthropic.com) and sign in.
2. Add credit under **Billing** (the agent uses the paid API).
3. Open **Settings → API Keys → Create Key** and copy the key (it starts with `sk-ant-`). You only see it once.

### 2. Download the agent

Open **PowerShell** (press the Windows key, type `PowerShell`, press Enter) and run:

```powershell
cd $HOME
git clone https://github.com/chericito/ia-agent-cheri.git
cd ia-agent-cheri
```

No git? On the GitHub page click **Code → Download ZIP**, unzip it, then `cd` into the folder in PowerShell.

### 3. Save your API key

Run this once, replacing the value with your key:

```powershell
[Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", "sk-ant-YOUR-KEY", "User")
```

**Close PowerShell and open it again** so it picks up the key. To check it's there:

```powershell
if ($env:ANTHROPIC_API_KEY) { "Key found" } else { "Key missing" }
```

### 4. Allow PowerShell to run the script (one time)

Windows blocks scripts by default. Allow scripts for your user only:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

If you downloaded the ZIP instead of using git, also unblock the file:

```powershell
Unblock-File .\agente.ps1
```

### 5. Start the evaluation

From the `ia-agent-cheri` folder:

```powershell
.\agente.ps1
```

## During the evaluation

- Type your answer and press **Enter**. You can answer "no sé" (I don't know).
- When a **memory task** appears, press Enter to see the stimulus. It disappears after a few seconds and the screen is cleared — that's intentional.
- Your response time is recorded automatically. Take the time you need.
- Type **`/salir`** at any moment to pause. Progress is saved after every answer.

## Next sessions

| What you want | Command |
|---|---|
| Continue where you left off | `.\agente.ps1` |
| Start over from scratch (old session is backed up) | `.\agente.ps1 -Nueva` |
| Run a separate evaluation (e.g. for another person) | `.\agente.ps1 -Sesion maria` |
| Lower the cost (less thorough evaluator) | `.\agente.ps1 -Esfuerzo medium` |

Remember to `cd` into the `ia-agent-cheri` folder first.

## Troubleshooting

| Message | Fix |
|---|---|
| `running scripts is disabled on this system` | Do step 4, or run once with `powershell -ExecutionPolicy Bypass -File .\agente.ps1` |
| `No hay credenciales` | The key isn't set: repeat step 3 and reopen PowerShell |
| `Error de la API (401)` | The key is wrong or was deleted: create a new one |
| `Error de la API (400)` mentioning credit/billing | Add credit in the Anthropic console |
| Accents look broken (`Ã³`) | Use **Windows Terminal** instead of the old blue PowerShell window |

## Cost

Each answer resends the conversation, so a full multi-session evaluation can cost a few US dollars. `-Esfuerzo medium` reduces it.

## Don't contaminate the test

`sesiones\*.json` (git-ignored) holds the correct answers and the evaluator's hidden notes. Don't open it until you're done.

## How it works

- **Hidden log**: the evaluator scores inside `<registro>` tags; the script never shows them, but saves them so the evaluator remembers between sessions.
- **Working memory**: stimuli inside `<memoria segundos="N">` are shown for N seconds, then the screen and scrollback are wiped.
- **Timing**: each answer silently carries how long you took to send it.

---

## Español

Agente de terminal (PowerShell) que hace una evaluación cognitiva conversacional usando la API de Claude (`claude-opus-5-5`). El prompt completo del evaluador está en `prompt_sistema.md`.

> Es una estimación experimental y conversacional, no una prueba clínica de IQ.

### Inicio rápido (paso a paso)

#### 1. Consigue una API key de Anthropic

1. Entra a [console.anthropic.com](https://console.anthropic.com) e inicia sesión.
2. Agrega crédito en **Billing** (el agente usa la API de pago).
3. Ve a **Settings → API Keys → Create Key** y copia la key (empieza con `sk-ant-`). Solo se muestra una vez.

#### 2. Descarga el agente

Abre **PowerShell** (tecla Windows, escribe `PowerShell`, Enter) y ejecuta:

```powershell
cd $HOME
git clone https://github.com/chericito/ia-agent-cheri.git
cd ia-agent-cheri
```

¿No tienes git? En la página de GitHub haz clic en **Code → Download ZIP**, descomprímelo y entra a la carpeta con `cd` en PowerShell.

#### 3. Guarda tu API key

Ejecuta esto una sola vez, reemplazando el valor por tu key:

```powershell
[Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", "sk-ant-TU-KEY", "User")
```

**Cierra PowerShell y vuelve a abrirlo** para que tome la key. Para comprobarlo:

```powershell
if ($env:ANTHROPIC_API_KEY) { "Key encontrada" } else { "Falta la key" }
```

#### 4. Permite que PowerShell ejecute el script (una sola vez)

Windows bloquea los scripts por defecto. Permítelos solo para tu usuario:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

Si descargaste el ZIP en vez de usar git, desbloquea también el archivo:

```powershell
Unblock-File .\agente.ps1
```

#### 5. Empieza la evaluación

Desde la carpeta `ia-agent-cheri`:

```powershell
.\agente.ps1
```

### Durante la evaluación

- Escribe tu respuesta y pulsa **Enter**. Puedes responder "no sé".
- Cuando aparezca una **tarea de memoria**, pulsa Enter para ver el estímulo. Desaparece a los pocos segundos y se borra la pantalla: es a propósito.
- Tu tiempo de respuesta se registra solo. Tómate el tiempo que necesites.
- Escribe **`/salir`** en cualquier momento para pausar. El progreso se guarda después de cada respuesta.

### Siguientes sesiones

| Qué quieres | Comando |
|---|---|
| Seguir donde lo dejaste | `.\agente.ps1` |
| Empezar de cero (la sesión anterior se respalda) | `.\agente.ps1 -Nueva` |
| Llevar otra evaluación aparte (p. ej. de otra persona) | `.\agente.ps1 -Sesion maria` |
| Bajar el costo (evaluador menos exhaustivo) | `.\agente.ps1 -Esfuerzo medium` |

Recuerda entrar primero a la carpeta `ia-agent-cheri` con `cd`.

### Solución de problemas

| Mensaje | Solución |
|---|---|
| `running scripts is disabled on this system` | Haz el paso 4, o ejecútalo una vez con `powershell -ExecutionPolicy Bypass -File .\agente.ps1` |
| `No hay credenciales` | Falta la key: repite el paso 3 y vuelve a abrir PowerShell |
| `Error de la API (401)` | La key es incorrecta o fue borrada: crea una nueva |
| `Error de la API (400)` que menciona crédito/billing | Agrega crédito en la consola de Anthropic |
| Los acentos se ven mal (`Ã³`) | Usa **Windows Terminal** en vez de la ventana azul antigua de PowerShell |

### Costo

Cada respuesta reenvía la conversación, así que una evaluación completa en varias sesiones puede costar unos pocos dólares. `-Esfuerzo medium` lo reduce.

### Para no contaminar la prueba

`sesiones\*.json` (ignorado por git) contiene las respuestas correctas y las notas ocultas del evaluador. No lo abras hasta terminar.

### Cómo funciona

- **Registro oculto**: el evaluador puntúa dentro de etiquetas `<registro>`; el script nunca las muestra, pero las guarda para que el evaluador recuerde entre sesiones.
- **Memoria de trabajo**: los estímulos en `<memoria segundos="N">` se muestran N segundos y luego se borra la pantalla y el scroll.
- **Tiempos**: cada respuesta lleva adjunto, sin que lo veas, cuánto tardaste en enviarla.
