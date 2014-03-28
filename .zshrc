# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="clean"
ZSH_THEME="gallois"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git autopep8 python github rails ruby history-substring-search gnu-utils autojump command-not-found)

source $ZSH/oh-my-zsh.sh

# User configuration

export PATH=$HOME/bin:/usr/local/bin:$PATH
export EDITOR='vim'
export WORKON_HOME="$HOME/.virtualenvs"
source /usr/bin/virtualenvwrapper.sh

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
alias -g .......='../../../../../..'

alias -s py=python

hash -d dl=~/Downloads
hash -d bot=~/robot/current/bot
hash -d 517=~/CSC517
hash -d proj=~/CSC517/csc517p1/backchannel
hash -d ex=~/CSC517/expertiza

zstyle ':completion:*' users-hosts root@192.168.7.2 daniel@10.0.0.2 ssh drfarrel@152.46.19.104 drfarrel@remote.eos.ncsu.edu

alias ping="ping -i .2"
alias pingg="ping www.google.com"
alias ping8="ping 8.8.8.8"
alias sw="time read -sn1"
alias starwars="telnet towel.blinkenlights.nl"
alias n="nload -u M wlan0"
alias s="source `eval echo ~$USER`/.zshrc"
alias aa="vim `eval echo ~$USER`/.zshrc"
alias df="df -h"
alias gdb="gdb -quiet"
alias top="top -d 1.5"
alias mtrg="mtr google.com"

RPROMPT=$RPROMPT'%{${fg[blue]}%}%*%{${fg[default]}%}'
