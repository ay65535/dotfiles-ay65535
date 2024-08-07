#!/bin/zsh

# https://zenn.dev/fuzmare/articles/zsh-plugin-manager-cache
# ファイル名を変数に入れる
target_dir=$ZDOTDIR/zoxide
cache_file="$target_dir/init.cache.zsh"
source_file="$target_dir/init.sh"
eval_cmd='zoxide init zsh'
#eval_cmd='zoxide init zsh --cmd cd'

ensure_zcompiled $source_file

# キャッシュがない、またはキャッシュが古い場合にキャッシュを作成
if [[ ! -r "$cache_file" || "$source_file" -nt "$cache_file" ]]; then
  mkdir -p "$target_dir"
  eval "$eval_cmd" >"$cache_file"
fi
source "$cache_file"
# 使い終わった変数を削除
unset target_dir cache_file source_file
