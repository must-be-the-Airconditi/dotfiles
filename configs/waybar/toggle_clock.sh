#!/bin/bash
STATE_FILE="/tmp/waybar_clock_state"

# 如果没有状态文件，初始化为 "time"
if [ ! -f "$STATE_FILE" ]; then
    echo "time" > "$STATE_FILE"
fi

# 如果传入了 toggle 参数，说明是被点击了，切换状态
if [ "$1" == "toggle" ]; then
    STATE=$(cat "$STATE_FILE")
    if [ "$STATE" == "time" ]; then
        echo "date" > "$STATE_FILE"
    else
        echo "time" > "$STATE_FILE"
    fi
    # 发送信号给 Waybar 强制刷新这个模块
    pkill -SIGRTMIN+8 waybar
    exit 0
fi

# 根据状态输出不同格式
STATE=$(cat "$STATE_FILE")
if [ "$STATE" == "time" ]; then
    date +"%H:%M:%S"  # 带秒的时间
else
    date +"%Y-%m-%d %H:%M" # 日期 + 时间
fi
