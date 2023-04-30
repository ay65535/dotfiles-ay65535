#!/bin/bash

mkdir -p ~/.local/src/github.com/junegunn
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.local/src/github.com/junegunn/fzf
~/.local/src/github.com/junegunn/fzf/install --xdg --key-bindings --completion --update-rc --no-fish
