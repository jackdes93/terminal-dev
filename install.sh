#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

info()  { printf '\033[1;34m[info]\033[0m  %s\n' "$1"; }
ok()    { printf '\033[1;32m[ok]\033[0m    %s\n' "$1"; }
warn()  { printf '\033[1;33m[warn]\033[0m  %s\n' "$1"; }
error() { printf '\033[1;31m[error]\033[0m %s\n' "$1"; }

# ---------------------------------------------------------------------------
# 1. Package manager + packages
# ---------------------------------------------------------------------------
install_with_brew() {
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

  local packages=(
    neovim tmux ripgrep fd fzf lazygit node go
    git curl wget jq eza asdf pyenv zsh-autosuggestions
  )
  [[ "$OS" == "Darwin" ]] && packages+=(reattach-to-user-namespace)

  info "Installing brew packages..."
  for pkg in "${packages[@]}"; do
    if brew list "$pkg" &>/dev/null; then
      ok "$pkg already installed"
    else
      info "Installing $pkg..."
      brew install "$pkg"
      ok "$pkg installed"
    fi
  done
}

install_with_apt() {
  info "Updating apt..."
  sudo apt-get update -qq

  local packages=(
    neovim tmux ripgrep fd-find fzf
    nodejs golang-go git curl wget jq zsh
    zsh-autosuggestions python3-venv
  )

  info "Installing apt packages..."
  for pkg in "${packages[@]}"; do
    if dpkg -s "$pkg" &>/dev/null 2>&1; then
      ok "$pkg already installed"
    else
      info "Installing $pkg..."
      sudo apt-get install -y -qq "$pkg"
      ok "$pkg installed"
    fi
  done

  # lazygit (not in default apt repos)
  if ! command -v lazygit &>/dev/null; then
    info "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    sudo tar xf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit
    rm /tmp/lazygit.tar.gz
    ok "lazygit installed"
  else
    ok "lazygit already installed"
  fi

  # eza
  if ! command -v eza &>/dev/null; then
    info "Installing eza..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
    sudo apt-get update -qq && sudo apt-get install -y -qq eza
    ok "eza installed"
  else
    ok "eza already installed"
  fi

  # pyenv
  if ! command -v pyenv &>/dev/null; then
    info "Installing pyenv..."
    curl -fsSL https://pyenv.run | bash
    ok "pyenv installed"
  else
    ok "pyenv already installed"
  fi

  # asdf
  if ! command -v asdf &>/dev/null; then
    info "Installing asdf..."
    git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf" --branch v0.14.1 2>/dev/null || true
    ok "asdf installed"
  else
    ok "asdf already installed"
  fi
}

install_with_dnf() {
  info "Installing packages with dnf..."
  local packages=(
    neovim tmux ripgrep fd-find fzf
    nodejs golang git curl wget jq zsh
    zsh-autosuggestions python3
  )

  for pkg in "${packages[@]}"; do
    if rpm -q "$pkg" &>/dev/null 2>&1; then
      ok "$pkg already installed"
    else
      info "Installing $pkg..."
      sudo dnf install -y -q "$pkg"
      ok "$pkg installed"
    fi
  done

  # lazygit
  if ! command -v lazygit &>/dev/null; then
    info "Installing lazygit..."
    sudo dnf copr enable -y atim/lazygit 2>/dev/null || true
    sudo dnf install -y -q lazygit
    ok "lazygit installed"
  else
    ok "lazygit already installed"
  fi

  # eza
  if ! command -v eza &>/dev/null; then
    info "Installing eza..."
    sudo dnf install -y -q eza 2>/dev/null || cargo install eza 2>/dev/null || warn "Could not install eza"
  fi

  # pyenv
  if ! command -v pyenv &>/dev/null; then
    info "Installing pyenv..."
    curl -fsSL https://pyenv.run | bash
    ok "pyenv installed"
  fi

  # asdf
  if ! command -v asdf &>/dev/null; then
    info "Installing asdf..."
    git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf" --branch v0.14.1 2>/dev/null || true
    ok "asdf installed"
  fi
}

install_with_pacman() {
  info "Installing packages with pacman..."
  local packages=(
    neovim tmux ripgrep fd fzf lazygit
    nodejs go git curl wget jq zsh eza python-pyenv
  )

  sudo pacman -Syu --noconfirm --needed "${packages[@]}"
  ok "pacman packages installed"

  # asdf
  if ! command -v asdf &>/dev/null; then
    info "Installing asdf..."
    git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf" --branch v0.14.1 2>/dev/null || true
    ok "asdf installed"
  fi
}

# Detect package manager and install
if [[ "$OS" == "Darwin" ]]; then
  install_with_brew
elif command -v apt-get &>/dev/null; then
  install_with_apt
elif command -v dnf &>/dev/null; then
  install_with_dnf
elif command -v pacman &>/dev/null; then
  install_with_pacman
else
  error "Unsupported package manager. Install packages manually: neovim tmux ripgrep fd fzf lazygit node go git curl wget jq eza zsh"
  exit 1
fi

# ---------------------------------------------------------------------------
# 2. Ensure zsh is default shell
# ---------------------------------------------------------------------------
if [[ "$SHELL" != *"zsh"* ]]; then
  ZSH_PATH="$(command -v zsh)"
  if [[ -n "$ZSH_PATH" ]]; then
    info "Changing default shell to zsh..."
    if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
      echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi
    chsh -s "$ZSH_PATH"
    ok "Default shell set to zsh"
  else
    warn "zsh not found — skipping shell change"
  fi
else
  ok "zsh is already the default shell"
fi

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
