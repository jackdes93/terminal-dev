# terminal-dev

Personal terminal config for macOS & Linux. One script to set up everything.

## What's included

| Tool | Config | Highlights |
|------|--------|------------|
| **Neovim** | `nvim/` | LazyVim, solarized-osaka theme, LSP for Go/TS/Vue/Python/Docker/SQL/YAML |
| **Tmux** | `tmux/` | Prefix `C-t`, vim-like pane navigation, solarized powerline statusline, lazygit popup |
| **Zsh** | `zsh/` | Oh My Zsh + Powerlevel10k, pyenv, asdf, eza aliases, pnpm |
| **Git** | `git/` | User config, global gitignore |

## Quick start

```bash
git clone git@github.com:jackdes93/terminal-dev.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## What `install.sh` does

1. **Installs packages** — detects OS and uses the right package manager:
   - macOS: Homebrew
   - Ubuntu/Debian: apt
   - Fedora/RHEL: dnf
   - Arch: pacman
2. **Sets zsh as default shell** (if not already)
3. **Creates symlinks** — backs up existing configs to `*.bak`
4. **Installs Oh My Zsh + Powerlevel10k**
5. **Syncs Neovim plugins** via lazy.nvim
6. **Installs tpm** (tmux plugin manager)

## Packages installed

neovim, tmux, ripgrep, fd, fzf, lazygit, node, go, git, curl, wget, jq, eza, asdf, pyenv, zsh-autosuggestions

macOS only: reattach-to-user-namespace

## Structure

```
dotfiles/
├── install.sh
├── nvim/
│   ├── init.lua
│   ├── lazy-lock.json
│   └── lua/
│       ├── config/        # options, keymaps, autocmds, lazy.nvim setup
│       ├── craftzdog/     # LSP, color utils
│       └── plugins/       # coding, editor, LSP, treesitter, UI, test
├── tmux/
│   ├── .tmux.conf         # root config (terminal setting)
│   ├── tmux.conf          # main config (keybindings, colors)
│   ├── statusline.conf    # solarized powerline statusline
│   ├── macos.conf         # clipboard + undercurl (macOS)
│   └── utility.conf       # lazygit popup
├── zsh/
│   ├── .zshrc             # main shell config (cross-platform)
│   ├── .zshenv            # flutter, cargo
│   ├── .zprofile          # Docker, Homebrew
│   └── .p10k.zsh          # Powerlevel10k theme
└── git/
    ├── .gitconfig          # user name/email, core settings
    ├── .gitignore_global   # global gitignore
    └── ignore              # XDG git ignore
```

## Symlinks created

| Source | Destination |
|--------|-------------|
| `nvim/` | `~/.config/nvim` |
| `tmux/` | `~/.config/tmux` |
| `tmux/.tmux.conf` | `~/.tmux.conf` |
| `zsh/.zshrc` | `~/.zshrc` |
| `zsh/.zshenv` | `~/.zshenv` |
| `zsh/.zprofile` | `~/.zprofile` |
| `zsh/.p10k.zsh` | `~/.p10k.zsh` |
| `git/.gitconfig` | `~/.gitconfig` |
| `git/.gitignore_global` | `~/.gitignore_global` |
| `git/ignore` | `~/.config/git/ignore` |
