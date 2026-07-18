# dots-hyprland (Arch-only Fork)

Personal Arch Linux fork of [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) — a Hyprland desktop shell with sidebar, AI chat, weather, and more.

**Changes from upstream:** Binary (non-git) dependencies only, Kitty terminal (no ghostty/matugen), bundled custom fonts, hardcoded weather coordinates.

## Quick Start

```bash
git clone https://github.com/Veridian-Zenith/dots-hyprland.git
cd dots-hyprland
./setup
```

## Setup Guide

### 1. Weather

Weather shows in your bar by default using [wttr.in](https://wttr.in) (free, no API key).

**Set your location** — edit `dots/.config/quickshell/ii/services/Weather.qml` and change the coordinates on the fallback line:

```
command += "/35.759200,-90.323100"  # ← replace with your lat,long
```

Find yours at [latlong.net](https://www.latlong.net/).

**Settings** (via Settings > Services):
- `useUSCS`: Toggle Fahrenheit (true) / Celsius (false)
- `fetchInterval`: How often to refresh (minutes)
- `city`: Display label only (does not affect queries)

### 2. AI Chat (Gemini)

The sidebar AI chat uses Google Gemini (free tier).

1. Get a key at [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)
2. Open the AI chat panel
3. Type `/key YOUR_API_KEY` and press Enter

The key is stored securely in your system keyring (GNOME Keyring).

**Optional: Local AI (Ollama)**
```bash
sudo pacman -S ollama
ollama serve &
ollama pull llama3
```
Ollama models auto-appear in the model picker — no API key needed.

**Optional: OpenRouter (DeepSeek, etc.)**
1. Get a key at [openrouter.ai/settings/keys](https://openrouter.ai/settings/keys)
2. In AI chat, type `/key YOUR_OPENROUTER_KEY`

### 3. Screen Translator (OCR)

Uses Google Cloud Vision API for text recognition on screen regions.

1. Create a project at [console.cloud.google.com](https://console.cloud.google.com)
2. Enable the **Cloud Vision API**
3. Create a **Service Account** and download the JSON key
4. Open the screen translator panel and paste the JSON key

### 4. Music Recognition

Identifies songs playing on your system (uses [SongRec](https://github.com/marinm/songrec) — local Shazam).

```bash
sudo pacman -S songrec
```

No API key needed. Set timeout/interval in Settings > Services.

### 5. Booru Image Browser

Browse images from booru sites in the sidebar. All providers are public (no keys).

**Available:** yande.re (default), Konachan, Danbooru, Gelbooru, waifu.im

**Zerochan users:** Set your username in Settings > Services to avoid being banned:
```
sidebar.booru.zerochan.username = "your_username"
```

### 6. Translator

Text translation in the sidebar using Google Translate via [translate-shell](https://github.com/soimort/translate-shell).

```bash
sudo pacman -S translate-shell
```

Configure in Settings > Language: source/target language, engine, delay.

### 7. KDE Connect (Phone Integration)

```bash
sudo pacman -S kdeconnect
```

Pair your phone via the KDE Connect app. Notifications and media control appear automatically.

### 8. Cloudflare WARP (VPN Toggle)

```bash
sudo pacman -S cloudflare-warp
sudo systemctl enable --now warp-svc
warp-cli registration new
warp-cli connect
```

Toggle appears in sidebar quick toggles.

## Keybinds

| Key | Action |
|-----|--------|
| `Super` | App launcher |
| `Super + E` | File manager (Dolphin) |
| `Super + Return` | Terminal (Kitty) |
| `Super + Q` | Kill window |
| `Super + M` | Music player |
| `Super + N` | Notification history |
| `Super + T` | Translator |
| `Super + V` | Clipboard history |
| `Print Screen` | Screenshot |

## Project Structure

```
dots/.config/
├── fish/              # Shell config
├── fontconfig/        # Font substitutions
├── hypr/              # Hyprland, hyprlock, hypridle
├── kitty/             # Terminal config
├── quickshell/ii/     # The shell UI (main codebase)
│   ├── modules/       # UI modules
│   ├── services/      # Backend services (Weather, Ai, etc.)
│   └── scripts/       # Helper scripts
└── wal/               # Pywal templates

sdata/
├── dist-arch/         # PKGBUILDs for Arch
├── lib/               # Shared install functions
└── subcmd-install/    # Install steps
```

## Credits

Based on [illogical-impulse](https://github.com/end-4/dots-hyprland) by end-4.
