#!/bin/bash
set -euo pipefail

# curl -fsSL https://raw.githubusercontent.com/darcien/dotfiles-preset-coder/master/setup-config-only.sh | bash

FLAG="$HOME/.dotfiles-preset-coder-setup-done"
if [ -f "$FLAG" ]; then
  echo "Setup already ran on $(cat "$FLAG"). Remove $FLAG to re-run."
  exit 0
fi

sudo timedatectl set-timezone Australia/Melbourne

cat >~/.gitconfig <<'EOF'
[core]
	editor = vim
[alias]
	s = status -s
	lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'
	lgt = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --tags
	co = checkout
[diff]
	algorithm = histogram
[log]
	date = iso
EOF

# ensure .zsh_history exists
touch ~/.zsh_history

# zsh - append to existing .zshrc instead of overwriting
cat >>~/.zshrc <<'EOF'
export LANG=en_US.UTF-8

# start zsh config - https://postgresqlstan.github.io/cli/zsh-history-options/
SAVEHIST=9000
HISTSIZE=9999                   # set HISTSIZE > SAVEHIST

setopt EXTENDED_HISTORY         # include timestamp
setopt HIST_BEEP                # beep if attempting to access a history entry which isn't there
setopt HIST_EXPIRE_DUPS_FIRST   # trim dupes first if history is full
setopt HIST_FIND_NO_DUPS        # do not display previously found command
setopt HIST_IGNORE_DUPS         # do not save duplicate of prior command
setopt HIST_IGNORE_SPACE        # do not save if line starts with space
setopt HIST_NO_STORE            # do not save history commands
setopt HIST_REDUCE_BLANKS       # strip superfluous blanks
setopt INC_APPEND_HISTORY       # don't wait for shell to exit to save history lines
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
EOF

# Mark setup as complete
date -Iseconds > "$FLAG"
echo "Setup complete."
