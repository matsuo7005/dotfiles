#!/usr/bin/fish

function setup_fisher
  # fish の prompt を書き換えるファイル
  # ~/.config/fish/functions/fish_prompt.fish
end

function setup_fish_plugins
  fisher add oh-my-fish/theme-bobthefish # https://github.com/oh-my-fish/theme-bobthefish
  fisher add 0rax/fish-bd # https://github.com/0rax/fish-bd

  # Ctrl + R でコマンド履歴を検索
  fisher add jethrokuan/fzf # https://github.com/jethrokuan/fzf
  git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
  ~/.fzf/install

  # bash script を fish で実行可能
  fisher add edc/bass # https://github.com/edc/bass

  fisher add oh-my-fish/theme-agnoster # https://github.com/oh-my-fish/theme-agnoster

  if test "$HOME/.config/fish/config.fish"
    source "$HOME/.config/fish/config.fish"
  end

  fish_update_completions
end

setup_fisher
setup_fish_plugins
