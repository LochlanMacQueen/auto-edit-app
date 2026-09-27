# auto-edit (app)

**One install:** a native macOS app that is the video editor *and* the auto-edit server. Your
agent (Claude Desktop / Claude Code / ChatGPT) connects to one MCP endpoint and can transcribe
takes, cut dead space, build the timeline, export with music, park the result in **Review**,
then run it through Instagram Edits on your iPhone and post it — captions and headers as
native Edits text, shared from the Instagram app.

- Editor: a fork of [Palmier Pro](https://github.com/palmier-io/palmier-pro) at its last GPL-3.0
  source (`last-gpl-source`), renamed, with the cloud account/generation/telemetry removed.
- Server + dashboard: bundled inside the app (`Contents/Resources/autoedit-runtime`: relocatable
  Python, ffmpeg, the [auto-edit](https://github.com/LochlanMacQueen/auto-edit) MCP server).
  The app starts it on launch and shows Review / Queue / Phone / Setup / Connect in the
  **auto-edit** menu.
- MCP: the agent connects to `http://127.0.0.1:4747/mcp` (Claude Desktop extension from the
  Connect panel); Palmier's own tools are reachable through it.

License: GPL-3.0 (see LICENSE). Palmier is a trademark of Palmier, Inc.; this fork is not
affiliated with or endorsed by Palmier.

## Build

Requires macOS 26, Apple Silicon, Xcode 27 (with the Metal Toolchain component:
`xcodebuild -downloadComponent MetalToolchain`).

```sh
swift build -c debug                     # compiles
# stage the runtime once (python-build-standalone 3.12 + static ffmpeg + the server code):
#   see scripts/stage-runtime.sh
scripts/bundle.sh debug                  # → .build/auto-edit.app (ad-hoc signed)
open .build/auto-edit.app
```

---

<div align="center">

# Palmier Pro

**The video editor built for AI.**

<a href="https://github.com/palmier-io/palmier-pro/releases/latest/download/PalmierPro.dmg">
  <img src="./assets/macos-badge.png" alt="Download Palmier Pro for macOS" width="180" />
</a>

<sub><i>Requires macOS 26 (Tahoe) on Apple Silicon</i></sub>

<a href="https://x.com/Palmier_io"><img src="https://img.shields.io/badge/Follow-%40Palmier__io-000000?style=flat&logo=x&logoColor=white" alt="Follow on X" /></a>
<a href="https://discord.com/invite/SMVW6pKYmg"><img src="https://img.shields.io/badge/Join-Discord-5865F2?style=flat&logo=discord&logoColor=white" alt="Join Discord" /></a>
<a href="https://www.ycombinator.com/companies/palmier"><img src="https://img.shields.io/badge/Y%20Combinator-S24-orange" alt="Y Combinator S24" /></a>
<br />
<a href="https://trendshift.io/repositories/41342?utm_source=repository-badge&amp;utm_medium=badge&amp;utm_campaign=badge-repository-41342" target="_blank" rel="noopener noreferrer"><img src="https://trendshift.io/api/badge/repositories/41342" alt="palmier-io%2Fpalmier-pro | Trendshift" width="250" height="55"/></a>

<p>
  <strong>English</strong> ·
  <a href="docs/readme/README.es.md">Español</a> ·
  <a href="docs/readme/README.zh-CN.md">简体中文</a> ·
  <a href="docs/readme/README.zh-TW.md">繁體中文</a> ·
  <a href="docs/readme/README.ja.md">日本語</a> ·
  <a href="docs/readme/README.ko.md">한국어</a> ·
  <a href="docs/readme/README.vi.md">Tiếng Việt</a> ·
  <a href="docs/readme/README.hi.md">हिन्दी</a> ·
  <a href="docs/readme/README.bn.md">বাংলা</a> ·
  <a href="docs/readme/README.ar.md">العربية</a> ·
  <a href="docs/readme/README.it.md">Italiano</a> ·
  <a href="docs/readme/README.pt-BR.md">Português (Brasil)</a> ·
  <a href="docs/readme/README.fr.md">Français</a> ·
  <a href="docs/readme/README.ru.md">Русский</a> ·
  <a href="docs/readme/README.tr.md">Türkçe</a>
</p>

</div>

<img src="./assets/palmier-ui.png" alt="Palmier Pro UI" width="900" />

---

Palmier Pro is an open source video editor for Mac. You and your agent can generate and edit videos together inside the timeline.

### Swift-native video editor

We built Palmier Pro from scratch with Swift. The north star is Premiere Pro, with our take on integrating AI into the workflow.

### Built-in Generative AI

Generate videos and images with SOTA models like Seedance, Kling, Nano Banana Pro inside the timeline editor.

### Integrates with your agents

Connects your Claude/Codex/Cursor via MCP, or use the in-app agent to work on the same project together.

## MCP server

When the app is open, it exposes an MCP server at `http://127.0.0.1:19789/mcp` via HTTP. To connect:

**Claude Code**
```bash
claude mcp add --transport http palmier-pro http://127.0.0.1:19789/mcp
```

**Codex**
```bash
codex mcp add palmier-pro --url http://127.0.0.1:19789/mcp
```

**Cursor**

The easiest way is go inside the app `Help` -> `MCP Instructions` -> `Install in Cursor`, or install manually by adding this to `~/.cursor/mcp.json`:

```
{
  "mcpServers": {
    "palmier-pro": {
      "type": "http",
      "url": "http://127.0.0.1:19789/mcp"
    }
  }
}
```

**Claude Desktop**

We bundle a [mcpb](https://github.com/modelcontextprotocol/mcpb) with the app that allows a one click install Desktop Extension on Claude Desktop. Go to `Help` -> `MCP Instructions` -> `Install in Claude Desktop`

## FAQ

**Is Palmier Pro fully open source?**

The video editor (without the generative AI features) is fully open source. The MCP server and the agent chat are also open source. The only thing that is closed source is the generative AI processing.

**Is it free?**

The editor is free. You can download it with no login required, and use it as a video editor like CapCut or Adobe Premiere. You can also use the MCP server for free, and start experimenting using Claude Code/Desktop or Cursor to interact with your timeline editor.

Generative AI features require login and subscription.

**What platforms does it support?**

macOS 26 (Tahoe) on Apple Silicon only.

See [FAQ.md](FAQ.md) for more.

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md)

## Community &amp; Support

- **Discord:** Join the community on **[Discord](https://discord.com/invite/SMVW6pKYmg)**.
- **Twitter / X:** Follow **[@Palmier_io](https://x.com/Palmier_io)** for updates and announcements.
- **Instagram:** Follow [@palmier.io](https://www.instagram.com/palmier.io) 
- **Feedback &amp; Support:** Create a [Github Issue](https://github.com/palmier-io/palmier-pro/issues) or email us at founders@palmier.io

## License

Copyright (C) 2026 Palmier, Inc.

Palmier Pro is open source under [GPLv3](LICENSE).
