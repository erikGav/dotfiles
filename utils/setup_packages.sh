#!/bin/bash


git_latest_tag() {
  local repo="$1"

  if [[ -z "$repo" ]]; then
    echo "usage: git_latest_tag <repo-url>" >&2
    return 1
  fi

  tag=$(git ls-remote --tags "$repo" \
    | awk '{print $2}' \
    | sed 's|refs/tags/||' \
    | grep -v '\^{}' \
    | sort -V \
    | tail -n 1)

  echo "${repo}/release/tag/${tag}"
}

jqp_repo="https://github.com/noahgorstein/jqp"
jq_repo="https://github.com/jqlang/jq"
yh_repo=""

jq_latest_tag=$(git_latest_tag "$jq_repo")
echo "$jq_latest_tag"

# Install Zsh
#sudo apt install -y zsh bat cmatrix gpg stow xclip 
#sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --skip-chsh
#sudo chsh -s $(which zsh)i
