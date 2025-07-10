#! /bin/bash

# install homebrew
# pipe from echo to avoid prompt
# https://github.com/Homebrew/legacy-homebrew/issues/46779#issuecomment-162819088
echo | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# (optional) eval for active session
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# install preferred formula
brew install git gh lazygit lazydocker mcfly spaceship

# custom .zshrc
mv ~/.zshrc ~/.zshrc.bak
cat >>~/.zshrc <<EOF
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

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

source $(brew --prefix)/opt/spaceship/spaceship.zsh

eval "$(mcfly init zsh)"

alias lg='lazygit'
alias ld='lazydocker'
EOF

# (optional) git config
# partially derived from https://github.com/darcien/dotfiles/blob/master/.gitconfig
cat >>~/.gitconfig <<EOF
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

# (optional) spaceship config
cat >>~/.spaceshiprc.zsh <<EOF
# https://spaceship-prompt.sh/config/prompt/
spaceship remove azure
spaceship remove docker
spaceship remove package
EOF
