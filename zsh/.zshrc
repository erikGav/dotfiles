autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C '/snap/aws-cli/current/bin/aws_completer' aws

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export XDG_CONFIG_HOME="$HOME/.config"
export ZSH="$HOME/.oh-my-zsh"
export EDITOR="code --wait"
export LANG=en_US.UTF-8

ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git aws docker terraform)

DEFAULT_USER=erikg
[[ ! -f $XDG_CONFIG_HOME/p10k/.p10k.zsh ]] || source $XDG_CONFIG_HOME/p10k/.p10k.zsh


source $ZSH/oh-my-zsh.sh
source $XDG_CONFIG_HOME/zsh/.zshrc_aliases
source $XDG_CONFIG_HOME/zsh/.zshrc_functions
source $XDG_CONFIG_HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"
