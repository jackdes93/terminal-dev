#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info()  { printf '\033[1;34m[info]\033[0m  %s\n' "$1"; }
ok()    { printf '\033[1;32m[ok]\033[0m    %s\n' "$1"; }
warn()  { printf '\033[1;33m[warn]\033[0m  %s\n' "$1"; }
error() { printf '\033[1;31m[error]\033[0m %s\n' "$1"; }

# ---------------------------------------------------------------------------
# 1. Homebrew
# ---------------------------------------------------------------------------
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ "$(uname -m)" == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  ok "Homebrew installed"
else
  ok "Homebrew already installed"
fi

# ---------------------------------------------------------------------------
# 2. Packages
# ---------------------------------------------------------------------------
BREW_PACKAGES=(
  neovim
  tmux
  ripgrep
  fd
  fzf
  lazygit
  node
  go
  git
  curl
  wget
  jq
  eza
  asdf
  pyenv
  reattach-to-user-namespace
  zsh-autosuggestions
)

info "Installing brew packages..."
for pkg in "${BREW_PACKAGES[@]}"; do
  if brew list "$pkg" &>/dev/null; then
    ok "$pkg already installed"
  else
    info "Installing $pkg..."
    brew install "$pkg"
    ok "$pkg installed"
  fi
done

# ---------------------------------------------------------------------------
# 3. Symlinks
# ---------------------------------------------------------------------------
link() {
  local src="$1" dst="$2"

  if [[ -L "$dst" ]]; then
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    warn "$dst exists and is not a symlink — backing up to ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  ok "linked $dst -> $src"
}

info "Creating symlinks..."

# Zsh
link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv"
link "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"
link "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

# Git
link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
link "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"
link "$DOTFILES_DIR/git/ignore" "$HOME/.config/git/ignore"

# Neovim
link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# Tmux — config directory
link "$DOTFILES_DIR/tmux" "$HOME/.config/tmux"

# Tmux — root .tmux.conf (sources ~/.config/tmux/tmux.conf internally)
link "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# ---------------------------------------------------------------------------
# 4. Oh My Zsh + Powerlevel10k
# ---------------------------------------------------------------------------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  info "Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ok "Oh My Zsh installed"
else
  ok "Oh My Zsh already installed"
fi

P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  info "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  ok "Powerlevel10k installed"
else
  ok "Powerlevel10k already installed"
fi

# ---------------------------------------------------------------------------
# 5. Neovim plugins (Lazy.nvim bootstrap)
# ---------------------------------------------------------------------------
info "Bootstrapping Neovim plugins (lazy.nvim)..."
if command -v nvim &>/dev/null; then
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
  ok "Neovim plugins synced"
else
  warn "nvim not found — skipping plugin sync"
fi

# ---------------------------------------------------------------------------
# 6. tmux plugin manager (tpm) — optional
# ---------------------------------------------------------------------------
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
  info "Installing tmux plugin manager (tpm)..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR" 2>/dev/null || true
  ok "tpm installed (prefix + I inside tmux to install plugins)"
else
  ok "tpm already installed"
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo ""
ok "Dotfiles setup complete!"
info "Open a new terminal or run: source ~/.zshrc"
info "Inside tmux: prefix + I to install tmux plugins (if using tpm)"
