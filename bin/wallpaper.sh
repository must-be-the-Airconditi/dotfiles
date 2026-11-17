#!/usr/bin/env bash
# wallpaper —— 壁纸启动器 + 选择器
#
# 设计原则：仓库不替用户决定壁纸。开机时用你自己选过的那张；
# 你还没选过，就先用 ~/Pictures 里第一张顶着（不会黑屏），并提示你去选。
#
# 用法：
#   wallpaper                 # 开机用：选过的图 → ~/Pictures 第一张 → 主题底色
#   wallpaper pick            # fuzzel 里挑一张，选择会记住
#   wallpaper set ~/a.jpg     # 直接指定并记住
#   wallpaper list            # 列出候选
#   wallpaper current         # 当前用的是哪张
#   wallpaper -m stretch      # 本次缩放模式：fill / fit / stretch / center / tile
#
# 你选的图记在 ~/.config/dotfiles/wallpaper（一行绝对路径），不进仓库。

set -o pipefail

MODE=fill
CONF_DIR="$HOME/.config/dotfiles"
CONF_FILE="$CONF_DIR/wallpaper"
PICTURES="$HOME/Pictures"

c_info=; c_ok=; c_warn=; c_err=; c_dim=; c_off=
if [ -t 1 ]; then
  c_info="$(printf "\033[1;36m")"; c_ok="$(printf "\033[1;32m")"
  c_warn="$(printf "\033[1;33m")"; c_err="$(printf "\033[1;31m")"
  c_dim="$(printf "\033[2m")";    c_off="$(printf "\033[0m")"
fi

say()  { printf "%s::%s %s\n" "$c_info" "$c_off" "$*"; }
ok()   { printf "%s✔%s %s\n" "$c_ok" "$c_off" "$*"; }
warn() { printf "%s!%s %s\n" "$c_warn" "$c_off" "$*"; }
die()  { printf "%s✘%s %s\n" "$c_err" "$c_off" "$*" >&2; exit 1; }

usage() {
  sed -n "2,19p" "$0" | sed "s/^# \{0,1\}//"
  exit 0
}

# ~/Pictures 下所有图片，按路径排序
list_images() {
  find "$PICTURES" -maxdepth 3 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    2>/dev/null | sort
}

is_image() { [ -n "$1" ] && [ -f "$1" ]; }

saved() { [ -s "$CONF_FILE" ] && head -n 1 "$CONF_FILE"; }

save() {
  mkdir -p "$CONF_DIR"
  printf "%s\n" "$1" > "$CONF_FILE"
}

# 真正拉起 swaybg。传入空值 = 底色兜底
apply() {
  img="$1"
  pkill -x swaybg 2>/dev/null
  sleep 0.2
  if is_image "$img"; then
    if command -v setsid >/dev/null 2>&1; then
      setsid --fork swaybg -i "$img" -m "$MODE" >/dev/null 2>&1 < /dev/null
    else
      nohup swaybg -i "$img" -m "$MODE" >/dev/null 2>&1 < /dev/null &
    fi
    ok "壁纸：$img  ${c_dim}($MODE)${c_off}"
  else
    if command -v setsid >/dev/null 2>&1; then
      setsid --fork swaybg -c "#1e1e2e" >/dev/null 2>&1 < /dev/null
    else
      nohup swaybg -c "#1e1e2e" >/dev/null 2>&1 < /dev/null &
    fi
    warn "还没有选壁纸，先用主题底色 #1e1e2e 顶着"
    warn "挑一张：${c_dim}wallpaper pick${c_off}   （把图放进 ~/Pictures 更容易挑）"
  fi
}

# 挑图优先级：环境变量 WALLPAPER → 你选过的 → ~/Pictures 第一张 → 空（底色）
resolve() {
  if is_image "$WALLPAPER"; then printf "%s" "$WALLPAPER"; return; fi
  s="$(saved)"
  if is_image "$s"; then printf "%s" "$s"; return; fi
  list_images | head -n 1
}

cmd_pick() {
  list="$(list_images)"
  if [ -z "$list" ]; then
    die "~/Pictures 里没有图片（jpg/jpeg/png/webp）。放几张进去，或用 wallpaper set /路径/图.png"
  fi
  count="$(printf "%s\n" "$list" | wc -l)"
  say "在 ~/Pictures 里找到 $count 张图"
  chosen=""
  if command -v fuzzel >/dev/null 2>&1; then
    chosen="$(printf "%s\n" "$list" | fuzzel --dmenu --lines 15 --prompt "壁纸 › " --width 60)"
  else
    printf "%s\n" "$list" | nl -w 2 -s ". "
    printf "输入编号（回车取消）："
    read -r idx
    if [ -n "$idx" ]; then
      chosen="$(printf "%s\n" "$list" | sed -n "$idx"p)"
    fi
  fi
  if [ -z "$chosen" ]; then warn "没选，保持原样"; exit 0; fi
  save "$chosen"
  apply "$chosen"
  printf "%s已记住，下次开机就用这张。%s\n" "$c_dim" "$c_off"
}

cmd_set() {
  p="$1"
  [ -z "$p" ] && die "用法：wallpaper set /路径/图片.jpg"
  if [ ! -f "$p" ]; then die "文件不存在：$p"; fi
  abs="$(cd "$(dirname "$p")" && pwd)/$(basename "$p")"
  save "$abs"
  apply "$abs"
  printf "%s已记住，下次开机就用这张。%s\n" "$c_dim" "$c_off"
}

cmd_list() {
  list="$(list_images)"
  if [ -z "$list" ]; then die "~/Pictures 里没有图片"; fi
  s="$(saved)"
  while IFS= read -r f; do
    if [ "$f" = "$s" ]; then printf "%s●%s %s\n" "$c_ok" "$c_off" "$f"
    else printf "  %s\n" "$f"; fi
  done <<< "$list"
  printf "%s● = 当前选定%s\n" "$c_dim" "$c_off"
}

cmd_current() {
  s="$(saved)"
  if is_image "$s"; then ok "已选定：$s"; else warn "还没选过壁纸（运行 wallpaper pick）"; fi
  printf "%s正在运行的 swaybg：%s\n" "$c_dim" "$(pgrep -a -x swaybg | head -n 1 || echo 无)$(printf "%s" "$c_off")"
}

case "$1" in
  ""|start|apply)
    img="$(resolve)"
    apply "$img"
    if [ -n "$img" ] && [ -z "$(saved)" ] && [ -z "$WALLPAPER" ]; then
      printf "%s还没选过壁纸，上面这张只是 ~/Pictures 里排第一的。想换：wallpaper pick%s\n" "$c_dim" "$c_off"
    fi ;;
  pick)            cmd_pick ;;
  set)             shift; cmd_set "$1" ;;
  list|ls)         cmd_list ;;
  current|status)  cmd_current ;;
  -m|--mode)       shift; MODE="$1"; apply "$(resolve)" ;;
  -h|--help|help)  usage ;;
  *)
    if is_image "$1"; then apply "$1"
    else die "未知参数：$1（wallpaper --help 看用法）"; fi ;;
esac
