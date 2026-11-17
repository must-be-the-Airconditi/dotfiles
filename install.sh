#!/usr/bin/env bash
# ============================================================================
#  Arch Linux Dotfiles · 一键安装脚本
#  Niri / MangoWM / Waybar / Fuzzel / Kitty / Zsh / Mako / Swaybg
#
#  用法:
#    ./install.sh                 完整安装（软件包 + 配置软链接）
#    ./install.sh --skip-packages 只做备份与软链接
#    ./install.sh --dry-run       预览操作，不改动任何文件
#    ./install.sh --help          显示帮助
# ============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$REPO_DIR/configs"
STAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="/tmp/dotfiles-install-$STAMP.log"

SKIP_PKGS=0
DRY_RUN=0

usage() {
  printf '%s\n' \
    "Arch Linux Dotfiles · 安装脚本" \
    "" \
    "用法: ./install.sh [选项]" \
    "" \
    "选项:" \
    "  --skip-packages   跳过软件包安装，只做配置备份与软链接" \
    "  --dry-run         预览将要执行的操作，不改动任何文件" \
    "  -h, --help        显示本帮助"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-packages) SKIP_PKGS=1 ;;
    --dry-run)       DRY_RUN=1 ;;
    -h|--help)       usage; exit 0 ;;
    *) printf '未知参数: %s（用 --help 查看用法）\n' "$1" >&2; exit 1 ;;
  esac
  shift
done

# ---------------------------------------------------------------------------
# 彩色输出
# ---------------------------------------------------------------------------
if [[ -t 1 ]]; then
  C_R=$'\033[1;31m'; C_G=$'\033[1;32m'; C_Y=$'\033[1;33m'
  C_B=$'\033[1;34m'; C_C=$'\033[1;36m'; C_M=$'\033[1;35m'
  C_D=$'\033[2m';    C_N=$'\033[0m'
else
  C_R=""; C_G=""; C_Y=""; C_B=""; C_C=""; C_M=""; C_D=""; C_N=""
fi

section() {
  printf '\n%s\n' "${C_M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_N}"
  printf '%s %s\n' "${C_C}▶${C_N}" "${C_B}$*${C_N}"
}
step() { printf '  %s %s\n' "${C_B}→${C_N}" "$*"; }
ok()   { printf '  %s %s\n' "${C_G}✔${C_N}" "$*"; }
warn() { printf '  %s %s\n' "${C_Y}⚠${C_N}" "$*"; }
err()  { printf '  %s %s\n' "${C_R}✘${C_N}" "$*" >&2; }
die()  { err "$*"; exit 1; }

run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '  %s %s\n' "${C_D}[dry-run]${C_N}" "$*"
  else
    if ! "$@" >>"$LOG_FILE" 2>&1; then
      err "命令失败: $*"
      tail -n 15 "$LOG_FILE" >&2 || true
      exit 1
    fi
  fi
}

# ---------------------------------------------------------------------------
# 依赖清单
# ---------------------------------------------------------------------------
REPO_PKGS=(
  # 窗口管理器
  niri mangowm
  # 桌面组件
  waybar mako fuzzel swaybg
  # 终端 / Shell
  kitty zsh
  # 编辑器 / IDE
  nano micro geany pycharm-community-edition
  # 开发环境
  direnv git
  # 配置中直接调用的系统工具
  grim slurp satty wl-clipboard brightnessctl playerctl
  pacman-contrib jq curl
  # 桌面集成
  polkit network-manager-applet pavucontrol blueman
  xdg-desktop-portal-gtk pipewire wireplumber
  # 输入法（mango 配置中启用）
  fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool
  # 锁屏 / 字体
  swaylock ttf-nerd-fonts-symbols noto-fonts noto-fonts-cjk
  # Zsh 插件
  zsh-autosuggestions zsh-syntax-highlighting
)

# 目前所有依赖都在官方仓库；若以后要加 AUR 包，填在这里
AUR_PKGS=()

OMZ_DIR="$HOME/.oh-my-zsh"
P10K_DIR="$OMZ_DIR/custom/themes/powerlevel10k"

# ---------------------------------------------------------------------------
# 0. 环境检查
# ---------------------------------------------------------------------------
section "环境检查"
[[ $EUID -eq 0 ]] && warn "正在以 root 运行，配置会写进 /root，通常不是想要的结果"
command -v pacman >/dev/null 2>&1 || die "未找到 pacman —— 本脚本仅适用于 Arch Linux"
ok "Arch Linux 环境正常"
step "仓库路径:   $REPO_DIR"
step "配置源目录: $CONFIG_SRC"
step "日志文件:   $LOG_FILE"
[[ $DRY_RUN -eq 1 ]] && warn "DRY-RUN 模式：不会修改任何文件"

# 便携性检查：所有配置都应使用 $HOME，而不是写死的 /home/<用户名>
if grep -rIq "/home/[a-zA-Z]" "$CONFIG_SRC" "$REPO_DIR/home" 2>/dev/null; then
  warn "以下位置仍写死了家目录路径（换用户名后会失效）："
  grep -rIn "/home/[a-zA-Z]" "$CONFIG_SRC" "$REPO_DIR/home" 2>/dev/null | sed 's/^/      /'
  warn "建议改成 \$HOME/... 写法"
else
  ok "配置全部使用 \$HOME，任意用户名均可安装"
fi

[[ -d "$CONFIG_SRC" ]] || die "找不到 $CONFIG_SRC，请在仓库根目录运行本脚本"

# ---------------------------------------------------------------------------
# 1. 软件包
# ---------------------------------------------------------------------------
if [[ $SKIP_PKGS -eq 1 ]]; then
  section "安装软件包"
  warn "已指定 --skip-packages，跳过软件包安装"
else
  section "安装官方仓库软件包 (pacman)"

  SUDO=""
  [[ $EUID -ne 0 ]] && SUDO="sudo"
  if [[ -n "$SUDO" ]] && ! command -v sudo >/dev/null 2>&1; then
    die "需要 sudo 但系统里没有（可直接用 root 运行）"
  fi

  missing=()
  for p in "${REPO_PKGS[@]}"; do
    pacman -Qq "$p" >/dev/null 2>&1 || missing+=("$p")
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    ok "全部 ${#REPO_PKGS[@]} 个软件包已安装"
  else
    step "待安装 ${#missing[@]} 个: ${missing[*]}"
    run $SUDO pacman -S --needed --noconfirm "${missing[@]}"
    ok "pacman 安装完成"
  fi

  if [[ ${#AUR_PKGS[@]} -gt 0 ]]; then
    section "安装 AUR 软件包 (yay)"
    if ! command -v yay >/dev/null 2>&1; then
      warn "未找到 yay，跳过: ${AUR_PKGS[*]}"
      warn "安装 yay: sudo pacman -S --needed base-devel git && git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si"
    else
      aur_missing=()
      for p in "${AUR_PKGS[@]}"; do
        yay -Qi "$p" >/dev/null 2>&1 || aur_missing+=("$p")
      done
      if [[ ${#aur_missing[@]} -eq 0 ]]; then
        ok "AUR 包已全部安装"
      else
        step "安装: ${aur_missing[*]}"
        run yay -S --needed --noconfirm "${aur_missing[@]}"
        ok "yay 安装完成"
      fi
    fi
  fi

  # -------------------------------------------------------------------------
  # 2. Zsh 环境
  # -------------------------------------------------------------------------
  section "配置 Zsh 环境"

  if [[ -d "$OMZ_DIR" ]]; then
    ok "Oh My Zsh 已存在: $OMZ_DIR"
  else
    step "安装 Oh My Zsh（不覆盖已有 .zshrc）"
    run git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
    ok "Oh My Zsh 安装完成"
  fi

  if [[ -d "$P10K_DIR" ]]; then
    ok "Powerlevel10k 已存在"
  else
    step "克隆 Powerlevel10k 主题"
    run git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    ok "Powerlevel10k 安装完成"
  fi

  section "刷新字体缓存"
  if command -v fc-cache >/dev/null 2>&1; then
    if [[ $DRY_RUN -eq 1 ]]; then
      printf '  %s %s\n' "${C_D}[dry-run]${C_N}" "fc-cache -f"
    else
      fc-cache -f >/dev/null 2>&1 && ok "字体缓存已刷新" || warn "fc-cache 失败（不影响配置）"
    fi
  else
    warn "未找到 fc-cache，跳过"
  fi
fi

# ---------------------------------------------------------------------------
# 3. 备份原有配置 + 建立软链接
# ---------------------------------------------------------------------------
section "备份原有配置并建立软链接"

# ---------------------------------------------------------------------------
#  软链接映射表  （仓库路径 => 系统路径）
#    configs/<应用>/  ->  ~/.config/<应用>/
#    home/<点文件>    ->  ~/<点文件>
#  新增应用时，在这里加一行即可
# ---------------------------------------------------------------------------
LINKS=(
  "configs/niri|$HOME/.config/niri"
  "configs/mango|$HOME/.config/mango"
  "configs/waybar|$HOME/.config/waybar"
  "configs/micro|$HOME/.config/micro"
  "configs/geany|$HOME/.config/geany"
  "configs/kitty|$HOME/.config/kitty"
  "home/zshrc|$HOME/.zshrc"
  "bin/wallpaper.sh|$HOME/.local/bin/wallpaper"
)

link_one() {
  local rel="$1" dst="$2" src
  src="$REPO_DIR/$rel"

  if [[ ! -e "$src" ]]; then
    warn "$rel 不存在，跳过"
    return 0
  fi

  if [[ -L "$dst" ]]; then
    step "已是软链接，重建: $dst"
    run rm -f "$dst"
  elif [[ -e "$dst" ]]; then
    step "备份: $dst  ->  $dst.bak-$STAMP"
    run mv "$dst" "$dst.bak-$STAMP"
  else
    step "新建: $dst"
  fi

  run mkdir -p "$(dirname "$dst")"
  run ln -sfn "$src" "$dst"
  ok "$dst  ==>  $src"
}

for entry in "${LINKS[@]}"; do
  link_one "${entry%%|*}" "${entry##*|}"
done

# ---------------------------------------------------------------------------
# 4. 脚本执行权限
# ---------------------------------------------------------------------------
section "修正脚本执行权限"
for f in \
  "$CONFIG_SRC/niri/screenshot.sh" \
  "$CONFIG_SRC/waybar/scripts/power_menu.sh" \
  "$CONFIG_SRC/waybar/scripts/toggle_clock.sh" \
  "$CONFIG_SRC/waybar/scripts/weather.sh" \
  "$REPO_DIR/bin/wallpaper.sh"; do
  if [[ -f "$f" ]]; then
    run chmod +x "$f"
    ok "chmod +x ${f#"$REPO_DIR"/}"
  fi
done

# ---------------------------------------------------------------------------
# 5. 完成
# ---------------------------------------------------------------------------
section "安装完成 🎉"

printf '\n'
printf '  %s\n' "${C_G}配置已就绪，重启会话或直接启动窗口管理器即可。${C_N}"
printf '\n'
printf '  %s\n' "${C_B}接下来可以：${C_N}"
printf '    %s\n' "${C_C}•${C_N} 启动 Niri（主力）  :  niri"
printf '    %s\n' "${C_C}•${C_N} 启动 MangoWM（备用）:  mango"
printf '    %s\n' "${C_C}•${C_N} 检查 Niri 配置     :  niri validate -c ~/.config/niri/config.kdl"
printf '    %s\n' "${C_C}•${C_N} 热重载 Niri 配置    :  niri msg action load-config-file"
printf '    %s\n' "${C_C}•${C_N} 选一张壁纸         :  wallpaper pick"
printf '\n'

# 第一次安装还没选过壁纸：交互式问一句，选完立刻生效
WP_CONF="$HOME/.config/dotfiles/wallpaper"
if [[ $DRY_RUN -eq 0 && ! -f "$WP_CONF" ]]; then
  printf '  %s\n' "${C_Y}还没有选壁纸。仓库不附带图片，用你自己的更好看。${C_N}"
  if [[ -t 0 && -t 1 ]]; then
    printf '  %s' "${C_B}现在从 ~/Pictures 里挑一张？[Y/n] ${C_N}"
    read -r answer
    if [[ ! "$answer" =~ ^[Nn] ]]; then
      "$HOME/.local/bin/wallpaper" pick || true
      if [[ -f "$WP_CONF" ]]; then
        ok "壁纸已选定，写在 $WP_CONF"
      else
        printf '  %s\n' "${C_D}跳过。之后随时运行 wallpaper pick${C_N}"
      fi
    fi
  else
    printf '  %s\n' "${C_D}非交互环境，跳过。之后运行：wallpaper pick${C_N}"
  fi
  printf '\n'
fi
printf '  %s\n' "${C_D}原配置已备份为 xxx.bak-$STAMP，确认无误后可自行删除。${C_N}"
printf '  %s\n' "${C_D}详细日志: $LOG_FILE${C_N}"
printf '\n'
