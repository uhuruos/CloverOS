HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

autoload -U compinit promptinit
compinit
promptinit; prompt gentoo

zstyle ':completion::complete:*' use-cache 1
