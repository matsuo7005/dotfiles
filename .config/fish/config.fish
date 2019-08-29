function fish_greeting
  echo ""
end

# cd > ls
function cd
  builtin cd $argv
    ls -a
end

# ls color
if test ! -e ~/.dircolors/dircolors.ansi-dark
  git clone https://github.com/seebi/dircolors-solarized.git ~/.dircolors
end
eval (dircolors -c ~/.dircolors/dircolors.ansi-dark)

# asdf
source ~/.asdf/asdf.fish

# Golang
set -x -U GOPATH $HOME/go
mkdir -p $GOPATH/bin
set -x PATH $PATH $GOPATH/bin

# Dart
set PATH /usr/lib/dart/bin $PATH

# alias
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'
