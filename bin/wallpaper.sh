#!/usr/bin/env bash
# wallpaper — 选 / 设 / 看当前壁纸
#
# 后端是 awww：awww-daemon 常驻，awww img 换图，awww restore 恢复上一张。
# 开机时 niri / mango 调 wallpaper（不带参数）把上次的壁纸接回来。
#
#   wallpaper               恢复上次的壁纸（开机自启动调它）
#   wallpaper pick          打开缩略图选择器（Quickshell），没有就退回 fuzzel
#   wallpaper set <图片>    设成指定图片
#   wallpaper next [图片]   换下一张 / 指定一张，带 wallfx 转场
#   wallpaper list          列出候选图片，● 是当前那张
#   wallpaper current       打印当前壁纸路径
#   wallpaper -m fit        缩放方式：fill（默认）/ fit / stretch / center
set -o pipefail

CONF_DIR="$HOME/.config/dotfiles"
CONF="$CONF_DIR/wallpaper"
MODE="crop"

say()  { printf '\033[1;34m›\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m✗\033[0m %s\n' "$*" >&2; exit 1; }
has()  { command -v "$1" >/dev/null 2>&1; }

help() {
  cat <<'EOF'
wallpaper — 选 / 设 / 看当前壁纸（后端 awww）

用法：wallpaper [命令] [参数] [-m 缩放方式]

命令：
  （无）            恢复上次的壁纸（开机自启动用这个）
  pick              缩略图选择器（Quickshell），没有就退回 fuzzel 列表
  set <图片>        设成指定图片
  next [图片]       换下一张；带 wallfx 像素转场
  list              候选图片，● 标出当前
  current           打印当前壁纸路径

选项：
  -m, --mode <方式>  fill / fit / stretch / center（默认 fill）
  -h, --help         显示本帮助

说明：~/.config/dotfiles/wallpaper 里记着你的选择，不进仓库、不影响别人。
没有图片时用主题底色 0x1e1e2e，不会黑屏。
EOF
}

mode_from_word() {
  case "$1" in
    fill|crop)     printf 'crop' ;;
    fit)           printf 'fit' ;;
    stretch)       printf 'stretch' ;;
    center|no)     printf 'no' ;;
    *)             return 1 ;;
  esac
}

images() {
  local d f
  for d in "$HOME/Pictures/wallpapers" "$HOME/Pictures"; do
    [ -d "$d" ] || continue
    for f in "$d"/*.jpg "$d"/*.jpeg "$d"/*.png "$d"/*.webp "$d"/*.gif; do
      [ -f "$f" ] && printf '%s\n' "$f"
    done
  done
  return 0
}

current() {
  awww query 2>/dev/null | sed -n 's/.*currently displaying: image: //p' | head -n 1
}

save() {
  mkdir -p "$CONF_DIR" 2>/dev/null || return 0
  printf '%s\n' "$1" > "$CONF" 2>/dev/null || warn "记不住选择（写不了 $CONF）"
  return 0
}

ensure_daemon() {
  has awww || { warn "没装 awww：sudo pacman -S awww"; return 1; }
  pgrep -x awww-daemon >/dev/null 2>&1 && return 0
  if has setsid; then
    setsid --fork awww-daemon >/dev/null 2>&1 || setsid awww-daemon >/dev/null 2>&1 &
  else
    nohup awww-daemon >/dev/null 2>&1 &
  fi
  local i=0
  while [ "$i" -lt 40 ]; do
    pgrep -x awww-daemon >/dev/null 2>&1 && return 0
    sleep 0.05
    i=$((i + 1))
  done
  warn "awww-daemon 没起来（这条命令要跑在 Wayland 会话里）"
  return 1
}

apply() {
  local img="$1" i=0
  case "$img" in
    0x*) ;;
    *) [ -f "$img" ] || { warn "图片不存在: $img"; return 1; } ;;
  esac
  ensure_daemon || return 1
  while [ "$i" -lt 40 ]; do
    case "$img" in
      0x*)
        if awww img "$img" --transition-type none >/dev/null 2>&1; then return 0; fi
        ;;
      *)
        if awww img "$img" --resize "$MODE" --transition-type none >/dev/null 2>&1; then return 0; fi
        ;;
    esac
    sleep 0.05
    i=$((i + 1))
  done
  warn "awww 设置壁纸失败: $img"
  return 1
}

restore_last() {
  local img
  if [ -n "$WALLPAPER" ] && [ -f "$WALLPAPER" ]; then
    apply "$WALLPAPER" && return 0
  fi
  ensure_daemon || return 1
  # awww 自己记着上次显示的那张，优先接回来
  awww restore >/dev/null 2>&1 && return 0
  if [ -s "$CONF" ]; then
    img="$(head -n 1 "$CONF")"
    if [ -n "$img" ] && [ -f "$img" ]; then apply "$img" && return 0; fi
  fi
  img="$(images | head -n 1)"
  if [ -n "$img" ]; then apply "$img" && return 0; fi
  apply 0x1e1e2e
  return 0
}

set_image() {
  local img="$1"
  if [ -z "$img" ]; then die "用法: wallpaper set <图片路径>"; fi
  [ -f "$img" ] || die "图片不存在: $img"
  img="$(readlink -f "$img")"
  if has wallpaper-next && has qs; then
    if wallpaper-next "$img" >/dev/null 2>&1; then
      save "$img"
      say "壁纸已换成 $(basename "$img")"
      return 0
    fi
  fi
  apply "$img" || die "设置失败"
  save "$img"
  say "壁纸已换成 $(basename "$img")"
}

pick() {
  if has wallpaper-pick && has qs; then
    exec wallpaper-pick
  fi
  has fuzzel || die "没有 fuzzel，也没有 wallpaper-pick。可以用 wallpaper set <图片> 直接设"
  local list sel
  list="$(images)"
  [ -n "$list" ] || die "~/Pictures 里没有图片，先放几张进去"
  sel="$(printf '%s\n' "$list" | sed "s|^$HOME/||" | fuzzel --dmenu --lines 15 --prompt '壁纸 › ')" || true
  [ -n "$sel" ] || return 0
  set_image "$HOME/$sel"
}

list_images() {
  local cur f mark
  cur="$(current)"
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    mark=" "
    if [ -n "$cur" ] && [ "$(readlink -f "$f")" = "$(readlink -f "$cur" 2>/dev/null)" ]; then
      mark="●"
    fi
    printf '%s %s\n' "$mark" "$f"
  done <<< "$(images)"
}

main() {
  local cmd
  while [ $# -gt 0 ]; do
    case "$1" in
      -m|--mode)
        shift
        [ $# -gt 0 ] || die "-m 需要一个参数：fill / fit / stretch / center"
        MODE="$(mode_from_word "$1")" || die "未知缩放方式: $1（fill / fit / stretch / center）"
        shift
        ;;
      -h|--help) help; exit 0 ;;
      *) break ;;
    esac
  done

  if [ $# -gt 0 ]; then cmd="$1"; else cmd=""; fi
  case "$cmd" in
    "")        restore_last ;;
    pick)      pick ;;
    set)       shift; set_image "$1" ;;
    next)      shift; exec wallpaper-next "$@" ;;
    list)      list_images ;;
    current)   current ;;
    *)         die "未知命令: $cmd（wallpaper --help 看用法）" ;;
  esac
}

main "$@"
