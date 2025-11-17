#! /bin/bash

sudo timedatectl set-timezone Australia/Melbourne

# brew installation is nuked on restart,
# but the config files in home dir are not.

# gitconfig with zdiff3 breaks brew installation as default git is too old
mv ~/.gitconfig ~/.gitconfig.bak

# install homebrew
# pipe from echo to avoid prompt
# https://github.com/Homebrew/legacy-homebrew/issues/46779#issuecomment-162819088
echo | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# (optional) eval for active session
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# install preferred formula
brew install git gh lazygit lazydocker mcfly starship

# (optional) git config
# partially derived from https://github.com/darcien/dotfiles/blob/master/.gitconfig
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

# check if .zshrc already been modified
if grep -q "eval.*mcfly init zsh" ~/.zshrc 2>/dev/null; then
    echo ".zshrc already contains our modifications. Exiting..."
    exit 0
fi

# custom .zshrc
mv ~/.zshrc ~/.zshrc.bak
# delimiter word must be quoted to avoid expansion in the heredoc
cat >>~/.zshrc <<'EOF'
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
EOF


# (optional) starship config
cat >>~/.config/starship.toml <<'EOF'
[time]
disabled = false
EOF
