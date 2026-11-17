#!/bin/bash
# 使用 Fuzzel 弹出的轻量级电源菜单

# 菜单选项，带图标
options="⏻ 关机\n󰜉 重启\n󰍃 注销\n 锁屏"

# 弹出 Fuzzel 菜单
chosen=$(echo -e "$options" | fuzzel --dmenu -p " ⚡ 电源 " --lines 4 --width 20)

# 根据选择执行命令
case "$chosen" in
    *"关机"*) systemctl poweroff ;;
    *"重启"*) systemctl reboot ;;
    *"注销"*) loginctl terminate-user $USER ;;
    *"锁屏"*) 
        if command -v swaylock &>/dev/null; then
            swaylock -f
        else
            notify-send "未安装锁屏工具" "请安装 swaylock"
        fi
        ;;
esac
