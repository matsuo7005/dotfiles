#!/bin/bash

# example.
#   RubyMine xxx.xxxx.xx
#   WebStorm xxx.xxxx.xx
#   Goland 1xxx.xxxx.xx
#   IDEA-U xxx.xxxx.xx
#   IDEA-JDK11 xxx.xxxx.xx

# ---------------------------------[functions]----------------------------------

# $1: Application Name
# $2: Version
setting_jetbrains_ide() {
  local version=$2
  local temp=$1
  local app_name=${1,,}

  if [ $1 == "RubyMine" -o $1 == "WebStorm" -o $1 == "Goland" ]; then
    local vmoptions_path="${HOME}/.local/share/JetBrains/Toolbox/apps/${1}/ch-0/${version}.vmoptions"
    local install_path="$HOME/.local/share/JetBrains/Toolbox/apps/${1}/ch-0/pleiades"
  else
    return
  fi

  # local install_path="$HOME/.local/share/JetBrains/Toolbox/apps/${1}/ch-0/pleiades"
  local filename="pleiades.zip"

  if [ ! -e "$HOME/Downloads/$filename" ]; then
    local uri="http://ftp.jaist.ac.jp/pub/mergedoc/pleiades/build/stable/${filename}"
    wget -O $HOME/Downloads/$filename $uri
  fi

  if [ ! -e "$install_path" ]; then
    unzip $HOME/Downloads/$filename -d $install_path
  fi

  local pleiades_path="${install_path}/plugins/jp.sourceforge.mergedoc.pleiades/pleiades.jar"

  if [ -e "$pleiades_path" ]; then
    tee -a $vmoptions_path << EOS > /dev/null
-Xverify:none
-javaagent:${pleiades_path}
-Dsun.java2d.uiScale.enabled=false
EOS
  fi
}

# ---------------------------------[execute]------------------------------------

setting_jetbrains_ide $1 $2
#!/usr/bin/env bash
