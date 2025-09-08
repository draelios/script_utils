#!/usr/bin/env bash
set -euo pipefail

# --------- sanity checks ----------
if ! command -v apt >/dev/null 2>&1; then
  echo "This script expects an Ubuntu/Debian-based WSL distro with apt." >&2
  exit 1
fi

# --------- packages ----------
sudo apt update
sudo apt install -y zsh git curl ca-certificates fzf

# --------- install Oh My Zsh (unattended) ----------
export RUNZSH=no  # don't auto-switch during install; we handle later
export CHSH=no    # let us control chsh explicitly
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "[+] Installing Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "[=] Oh My Zsh already installed"
fi

# --------- plugins: autosuggestions + syntax highlighting ----------
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  (cd "$ZSH_CUSTOM/plugins/zsh-autosuggestions" && git pull --ff-only || true)
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  (cd "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" && git pull --ff-only || true)
fi

# --------- install Starship prompt ----------
if ! command -v starship >/dev/null 2>&1; then
  echo "[+] Installing Starship"
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
else
  echo "[=] Starship already installed"
fi

# --------- write ~/.zshrc (backup existing) ----------
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ] && [ ! -f "$ZSHRC.bak" ]; then
  cp "$ZSHRC" "$ZSHRC.bak"
fi

cat > "$ZSHRC" << "EOF"
# --- Zsh base ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(
  git
  fzf
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# --- Starship prompt ---
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# --- fzf defaults (Ctrl-R, Ctrl-T enhancements) ---
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# --- nice aliases ---
alias ll="ls -alF"
alias la="ls -A"
alias gs="git status -sb"
alias gc="git commit"
alias gp="git push"
alias gl="git pull --rebase"

# Prefer colorized grep/ls if available
export CLICOLOR=1
export LESS=-R
EOF

# Ensure zsh is a valid login shell
ZSH_PATH="$(command -v zsh)"
if ! grep -q "^$ZSH_PATH$" /etc/shells 2>/dev/null; then
  echo "[+] Adding $ZSH_PATH to /etc/shells"
  echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null || true
fi

# --------- set default shell to zsh ----------
echo "[+] Setting your login shell to zsh"
if command -v chsh >/dev/null 2>&1; then
  chsh -s "$ZSH_PATH" "$USER" || true
fi
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_PATH" ]; then
  # Fallback for WSL environments where chsh is ignored
  sudo usermod -s "$ZSH_PATH" "$USER" || true
fi

# --------- WSL-friendly fallback: auto-exec zsh from bash ----------
# This ensures that if WSL starts bash (e.g., some launchers), it jumps into zsh.
BASHRC="$HOME/.bashrc"
if ! grep -q "exec zsh" "$BASHRC" 2>/dev/null; then
  cat >> "$BASHRC" << "EOSH"
# Auto-start zsh if interactive and not already in zsh
if [ -t 1 ] && [ -n "$PS1" ] && [ -z "$ZSH_VERSION" ]; then
  exec zsh
fi
EOSH
fi

echo
echo "✅ Done! Close and reopen your WSL terminal. You should land in Zsh with Starship."
echo "   - Your old .zshrc (if any) was backed up to ~/.zshrc.bak"
echo "   - To tweak prompt: run  \`starship preset\`  or edit ~/.zshrc"
