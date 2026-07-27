#!/bin/env bash

mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.tar.xz
tar -xvf FiraCode.tar.xz
rm FiraCode.tar.xz
fc-cache -fv
