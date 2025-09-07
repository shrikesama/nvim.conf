# Repository Guidelines

## Project Structure & Module Organization
- Entry point: `init.lua` (bootstraps plugins and core).
- Core config: `lua/core/` (e.g., `options.lua`, `keymaps.lua`, `gui.lua`, `utils.lua`).
- Plugins: `lua/plugins/` grouped by feature (`language.lua`, `editor.lua`, `appearance.lua`, etc.).
- Plugin manager: `lua/lazyconf.lua`; lockfile: `lazy-lock.json`.
- Utilities: `lua/utils/` for shared helpers.

## Build, Test, and Development Commands
- Run Neovim with this config: `nvim -u init.lua`.
- Isolated sandbox (Bash): `NVIM_APPNAME=nvim-test nvim`.
- Isolated sandbox (PowerShell): `$env:NVIM_APPNAME = "nvim-test"; nvim`.
- Manage plugins (inside Neovim): `:Lazy sync` (install/update), `:Lazy clean`, `:Lazy log`.
- Health checks: `:checkhealth` (validate LSP/treesitter/providers).

## Coding Style & Naming Conventions
- Language: Lua 5.1 (Neovim runtime). Indent with 2 spaces, no tabs.
- Naming: files/modules `snake_case.lua`; local vars/functions `snake_case`; exported tables `snake_case` keys.
- Structure: keep feature-specific logic in the matching `lua/plugins/*` or `lua/core/*` file.
- Formatting: prefer idiomatic Lua; avoid global state; side effects only in module `setup()`.

## Testing Guidelines
- Manual verification: open a project and run `:Lazy sync`, `:checkhealth`.
- LSP: open a language file and verify diagnostics, formatting, and completion.
- Treesitter: `:TSInstall <lang>` if missing; confirm highlighting.
- Regressions: test startup with `--clean` profile via `NVIM_APPNAME` as above.

## Commit & Pull Request Guidelines
- Use Conventional Commits: `feat(scope): ...`, `fix(scope): ...`, `refactor(scope): ...`.
- Commits should be focused and descriptive; reference issues when relevant.
- PRs must include: purpose/summary, notable changes, screenshots/gifs for UI, and manual test notes.
- Keep changes minimal; align with existing file layout and plugin grouping.

## Security & Configuration Tips
- Do not commit machine-specific secrets or paths; prefer environment checks in `utils`.
- When adding plugins, pin versions via `lazy-lock.json` and include safe defaults disabled by default if intrusive.
