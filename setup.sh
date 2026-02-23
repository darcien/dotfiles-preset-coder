#!/bin/bash
set -euo pipefail

sudo timedatectl set-timezone Australia/Melbourne

sudo apt-get update
sudo apt-get install -y build-essential pkg-config libssl-dev # for cc and openssl


# disable existing .gitconfig first.
# zdiff3 in gitconfig breaks brew install (default git too old)
[[ -f ~/.gitconfig ]] && mv ~/.gitconfig ~/.gitconfig.bak

# homebrew
if ! command -v brew &>/dev/null; then
  # pipe from echo to avoid prompt
  # https://github.com/Homebrew/legacy-homebrew/issues/46779#issuecomment-162819088
  echo | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install git gh lazygit lazydocker mcfly starship

# uv
if ! command -v uv &>/dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# opencode
if ! npm ls -g opencode-ai &>/dev/null; then
  npm i -g opencode-ai
fi

mkdir -p ~/.config/opencode
cat >~/.config/opencode/opencode.jsonc <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "model": "github-copilot/claude-sonnet-4.6",
  "instructions": [".github/copilot-instructions.md", ".github/instructions/*.md"],
  "skills": {
    "paths": [".github/skills/**/SKILL.md"]
  }
}
EOF

# git config
cat >~/.gitconfig <<'EOF'
[core]
	editor = code --wait
[alias]
	s = status -s
	lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'
	lgt = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --tags
	co = checkout
[merge]
	conflictstyle = zdiff3
[diff]
	algorithm = histogram
[log]
	date = iso
EOF

# ensure .zsh_history exists for mcfly
touch ~/.zsh_history

# zsh
cat >~/.zshrc <<'EOF'
export LANG=en_US.UTF-8

# start zsh config - https://postgresqlstan.github.io/cli/zsh-history-options/
SAVEHIST=9000
HISTSIZE=9999                   # set HISTSIZE > SAVEHIST

setopt EXTENDED_HISTORY         # include timestamp
setopt HIST_BEEP                # beep if attempting to access a history entry which isn’t there
setopt HIST_EXPIRE_DUPS_FIRST   # trim dupes first if history is full
setopt HIST_FIND_NO_DUPS        # do not display previously found command
setopt HIST_IGNORE_DUPS         # do not save duplicate of prior command
setopt HIST_IGNORE_SPACE        # do not save if line starts with space
setopt HIST_NO_STORE            # do not save history commands
setopt HIST_REDUCE_BLANKS       # strip superfluous blanks
setopt INC_APPEND_HISTORY       # don’t wait for shell to exit to save history lines
# end zsh config

# Cycle through history based on characters already typed on the line
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search    # Up arrow
bindkey "^[[B" down-line-or-beginning-search  # Down arrow
bindkey "^[OA" up-line-or-beginning-search    # Up arrow (alternate)
bindkey "^[OB" down-line-or-beginning-search  # Down arrow (alternate)

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

eval "$(starship init zsh)"

eval "$(mcfly init zsh)"

alias lg='lazygit'
alias ld='lazydocker'

export PATH="$(npm config get prefix)/bin:$PATH"
EOF

# starship
mkdir -p ~/.config
cat >~/.config/starship.toml <<'EOF'
[time]
disabled = false
EOF
