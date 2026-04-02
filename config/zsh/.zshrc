autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C './usr/loca/bin/aws_completer' aws

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export XDG_CONFIG_HOME="$HOME/.config"
export ZSH="$HOME/.oh-my-zsh"
export EDITOR="code --wait"
export GTK_THEME="Material-Black-Mango"
export GPG_TTY=$TTY
export LANG=en_US.UTF-8

if grep -qi microsoft /proc/version 2>/dev/null; then
  export BROWSER="wslview:xdg-open"
else
  export BROWSER="brave-browser"
fi

ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git aws docker docker-compose terraform kubectl)

DEFAULT_USER=erikg
[[ ! -f $XDG_CONFIG_HOME/p10k/.p10k.zsh ]] || source $XDG_CONFIG_HOME/p10k/.p10k.zsh

# p10k custom segment: show container type when running inside a container
function prompt_my_container() {
  local name=""
  if [[ -f /.dockerenv ]]; then
    name="docker"
  elif [[ -f /run/.containerenv ]]; then
    name=$(grep -oP '(?<=name=")[^"]+' /run/.containerenv 2>/dev/null)
    name="${name:-podman}"
  elif grep -qa 'docker\|lxc' /proc/1/cgroup 2>/dev/null; then
    name="container"
  fi
  [[ -n "$name" ]] && p10k segment -b 4 -f 7 -i '󰡨' -t "$name"
}


source $ZSH/oh-my-zsh.sh
source $XDG_CONFIG_HOME/zsh/.zshrc_aliases
source $XDG_CONFIG_HOME/zsh/.zshrc_functions
source $XDG_CONFIG_HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

if [ -z "$SSH_AUTH_SOCK" ]; then
      eval $(ssh-agent -s) > /dev/null 2>&1
fi

export NVM_DIR="$HOME/.config/nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
fi
if [ -s "$NVM_DIR/bash_completion" ]; then
  . "$NVM_DIR/bash_completion"
fi
true  # Force success status
