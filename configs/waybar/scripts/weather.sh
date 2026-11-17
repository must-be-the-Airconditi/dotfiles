#!/bin/bash
CITY="Hefei" # 空着则自动通过 IP 定位，也可填 "Beijing", "Shanghai" 等
LANG_CODE="zh" # 中文

# 使用 jq 构造 Waybar 需要的 JSON 格式
weather=$(curl -s "https://wttr.in/${CITY}?format=j1&lang=${LANG_CODE}")

if [ -z "$weather" ]; then
    echo '{"text": "󰖐 N/A", "tooltip": "无法获取天气数据"}'
    exit 0
fi

# 提取数据
temp_C=$(echo "$weather" | jq -r '.current_condition[0].temp_C')
weather_desc=$(echo "$weather" | jq -r '.current_condition[0].lang_zh[0].value // .current_condition[0].weatherDesc[0].value')
humidity=$(echo "$weather" | jq -r '.current_condition[0].humidity')
feels_like=$(echo "$weather" | jq -r '.current_condition[0].FeelsLikeC')

# 根据天气代码选择 Nerd Font 图标
code=$(echo "$weather" | jq -r '.current_condition[0].weatherCode')
case $code in
    113) icon="󰖙" ;; # 晴
    116) icon="󰖕" ;; # 多云
    119|122) icon="󰖐" ;; # 阴
    176|263|266|293|296) icon="󰖗" ;; # 小雨
    299|302|305|308) icon="󰖘" ;; # 中/大雨
    200|386|389) icon="󰙾" ;; # 雷雨
    227|230|323|326|329|332|335|338) icon="󰼶" ;; # 雪
    143|248|260) icon="󰖑" ;; # 雾
    *) icon="󰖐" ;; # 默认
esac

# 输出 Waybar JSON 格式
echo "{\"text\": \"${icon} ${temp_C}°C\", \"tooltip\": \"${weather_desc}\\n体感温度: ${feels_like}°C\\n湿度: ${humidity}%\"}"
