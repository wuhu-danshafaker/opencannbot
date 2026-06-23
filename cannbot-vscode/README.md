# CANNBot Chat for VS Code

Use [CANNBOT](https://cannbot.hicann.cn) models directly in **VS Code native Chat** via `@cannbot`.

No Python proxy, no third-party extension — just install and set your Virtual Key.

## Features

- 🎯 **`@cannbot`** participant in VS Code's built-in Chat UI (`Ctrl+Shift+I` / `Cmd+Shift+I`)
- 🔄 **Streaming responses** — see output as it's generated
- 📋 **Model listing** — `@cannbot /models` to browse available models
- 🔐 **VK→JWT auth** — automatic token exchange and caching
- ⚙️ **Configurable** — model, temperature, VK all in Settings

## Quick Start

### 1. Install the extension

```bash
# Either install from VSIX:
code --install-extension cannbot-vscode-0.1.0.vsix

# Or copy the cannbot-vscode folder to ~/.vscode/extensions/
```

### 2. Set your Virtual Key

**Option A — Command Palette:**
1. Open Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`)
2. Run **`CANNBot: Set Virtual Key`**
3. Enter your `vk-xxxx...` key

**Option B — Settings:**
1. Open Settings (`Ctrl+,` / `Cmd+,`)
2. Search for `cannbot.virtualKey`
3. Paste your Virtual Key

### 3. Start chatting

1. Open VS Code Chat (`Ctrl+Shift+I` / `Cmd+Shift+I`)
2. Type `@cannbot hello` and press Enter
3. Or try `@cannbot /models` to list available models

## Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `cannbot.virtualKey` | `""` | Your CANNBOT Virtual Key (`vk-xxxx`) |
| `cannbot.defaultModel` | `"glm-5.1"` | Default model ID |
| `cannbot.temperature` | `0.3` | Model temperature (0.0–2.0) |

## Commands

| Command | Description |
|---------|-------------|
| `CANNBot: Set Virtual Key` | Set or update your VK |
| `CANNBot: Clear Virtual Key` | Remove configured VK |
| `CANNBot: Show connection status` | Quick status check |

## Chat Commands

| Command | Description |
|---------|-------------|
| `@cannbot /models` | List all available CANNBOT models |
| `@cannbot /status` | Show connection and JWT status |
| `@cannbot /help` | Show help |

## How It Works

```
VS Code Chat  ──→  @cannbot participant  ──→  CANNBOT Gateway
                                                    │
    ┌───────────────────────────────────────────────┘
    │
    ├─ VK→JWT exchange (in TypeScript, no proxy needed)
    ├─ Streaming SSE responses
    └─ JWT caching with auto-refresh
```

The extension handles VK→JWT authentication natively in TypeScript — no Python proxy or external process required. It communicates directly with `https://cannbot.hicann.cn/gateway/compatible-mode/v1`.

## Requirements

- VS Code 1.85+
- A CANNBOT Virtual Key (get one at [cannbot.hicann.cn](https://cannbot.hicann.cn))

## Building from Source

```bash
cd cannbot-vscode
npm install
npm run compile
npm run package   # produces cannbot-vscode-0.1.0.vsix
```

## License

MIT
