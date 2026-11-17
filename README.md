# Arch Linux Dotfiles

> Niri 主力 · MangoWM 兜底 · Waybar 状态栏 · Kitty + Zsh 终端
> 一套 `git clone` 完就能跑起来的 Arch Wayland 桌面配置。

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat-square&logo=arch-linux&logoColor=white)
![Wayland](https://img.shields.io/badge/Wayland-FFBC00?style=flat-square&logo=wayland&logoColor=black)
![Shell](https://img.shields.io/badge/Shell-Zsh-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)
![WM](https://img.shields.io/badge/WM-Niri_%2F_MangoWM-89b4fa?style=flat-square)

---

## ✨ 概览

| 类别 | 软件 | 说明 |
| :--- | :--- | :--- |
| 窗口管理器（主力） | **Niri** | 滚动平铺、圆角毛玻璃、平滑动画 |
| 窗口管理器（备用） | **MangoWM** | 轻量 dwm 风格，崩溃时用来救场 |
| 状态栏 | **Waybar** | 天气 / 音量 / 亮度 / 网络 / 托盘 / 电源菜单 |
| 启动器 | **Fuzzel** | Wayland 原生，轻快到起飞 |
| 终端 | **Kitty** | GPU 加速 + Catppuccin 配色 |
| Shell | **Zsh** | Oh My Zsh + Powerlevel10k + autosuggestions |
| 通知 | **Mako** | 带毛玻璃效果 |
| 壁纸 | **Swaybg** | 由 compositor 开机自动拉起 |
| 编辑器 / IDE | **nano / micro / Geany / PyCharm** | 终端里 nano、micro，图形界面 Geany、PyCharm |
| Python 环境 | **direnv** | 进目录自动加载 `.envrc` 虚拟环境 |

---

## 📂 仓库结构

`@
dotfiles/
├── configs/
│   ├── niri/            # Niri 主配置（config.kdl + 截图脚本）
│   ├── mango/           # MangoWM 备用配置
│   ├── waybar/          # 状态栏：config.jsonc / style.css / 脚本
│   ├── micro/           # micro 编辑器键位绑定
│   ├── geany/           # Geany 配色与键位
│   ├── kitty/           # 终端配置 + 主题
│   └── zshrc            # Zsh 配置（链接到 ~/.zshrc）
├── install.sh           # 一键安装脚本（备份 + 软链接）
├── .gitignore           # 屏蔽私钥 / 日志 / 缓存 / 备份
└── README.md
`@

> 仓库里**只放配置文件**，不放私钥、密码、聊天记录或任何凭据。

---

## 🚀 安装

### 前置条件

- 一台 Arch Linux（或 Arch 系）机器，能联网
- 普通用户具备 `sudo` 权限
- 只有需要装 AUR 包时才需要 `yay`（当前依赖全在官方仓库）

### 三步走

`@bash
# 1. 克隆
git clone https://github.com/must-be-the-Airconditi/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. 赋予执行权限
chmod +x install.sh

# 3. 跑起来
./install.sh
`@

脚本跑完会打印彩色进度，最后告诉你下一步该干什么。

### 可选参数

| 参数 | 作用 |
| :--- | :--- |
| `--skip-packages` | 跳过软件包安装，只做备份 + 软链接（适合软件已装好的情况） |
| `--dry-run` | 预览将要执行的所有操作，**不修改任何文件** |
| `-h` / `--help` | 查看帮助 |

建议第一次先跑 `./install.sh --dry-run` 看看它打算动哪些文件。

### install.sh 具体做了什么

1. **检查环境**：确认是 Arch、有 `pacman`、配置目录存在。
2. **安装软件包**：用 `pacman -S --needed` 装齐全部依赖（已装好的自动跳过，不重复折腾）。
3. **配置 Zsh**：缺少 Oh My Zsh / Powerlevel10k 时自动克隆（已存在则跳过，**不覆盖**你的 `.zshrc`）。
4. **备份旧配置**：把已有的 `~/.config/xxx` 改名为 `xxx.bak-<时间戳>`，**绝不删除**。
5. **建立软链接**：`ln -sfn ~/dotfiles/configs/xxx ~/.config/xxx`，以后改配置直接改仓库。
6. **修正权限**：给截图、电源菜单等脚本加 `+x`。

> ⚠️ 安全设计：脚本**只做 `mv` 备份和 `ln` 软链接**，不会覆盖或删除你系统里已存在的任何文件。

---

## ⌨️ 快捷键

### Niri（主力）

| 快捷键 | 功能 |
| :--- | :--- |
| `Mod + T` | 打开 Kitty |
| `Mod + D` | 打开 Fuzzel 启动器 |
| `Mod + Q` | 关闭当前窗口 |
| `Mod + F` | 当前列最大化 |
| `Mod + Shift + F` | 切换浮动窗口 |
| `Mod + Shift + S` | 区域截图（grim + slurp + satty） |
| `Mod + ← / →` | 切换列焦点 |
| `Mod + ↑ / ↓` | 切换窗口焦点 |
| `Mod + 1/2/3` | 切换到对应工作区 |

### MangoWM（备用）

| 快捷键 | 功能 |
| :--- | :--- |
| `SUPER + Enter` / `SUPER + T` | 打开 Kitty |
| `SUPER + D` | 打开 Fuzzel |
| `SUPER + Q` | 关闭窗口 |
| `SUPER + F` | 切换全屏 |
| `SUPER + Shift + R` | 重新加载配置 |
| `SUPER + Shift + E` | 退出 MangoWM |

---

## 🆘 紧急救援：Niri 崩溃黑屏怎么办

保留 **MangoWM** 的主要原因就在这里——万一 Niri 配置写崩了、显卡驱动抽风，你至少还有一个能用的图形界面可以救场。

### 典型症状

- 登录后**黑屏**，只有一个鼠标指针
- 屏幕卡死、快捷键全部无响应
- 壁纸出来了，但 Waybar / 窗口起不来

### 救援步骤

**① 先等 10 秒，别急着砸键盘**

Niri 支持会话自动恢复，有时只是动画卡住，等一会儿会自己回来。超过 30 秒没动静再动手。

**② 切到 TTY**

`@
Ctrl + Alt + F2
`@

> `F1`–`F6` 逐个试，总有一个能进。部分笔记本键盘需要 `Fn` 组合键。
> 看到 `login:` 提示符就说明成功了，输入**用户名**和**密码**（密码输入时屏幕不显示任何字符，这是正常的）。

**③ 先定位问题，再动手**

`@bash
# 看最近的错误日志
journalctl -b -p err --no-pager | tail -50

# 检查 Niri 配置语法 —— 90% 的黑屏都是配置写错了
niri validate -c ~/.config/niri/config.kdl

# 确认 Niri 进程状态
pgrep -a niri
`@

如果 `niri validate` 报错，那基本就是配置的问题。

**④ 配置写坏了？直接回滚**

`@bash
cd ~/dotfiles
git log --oneline -5                   # 看看最近改了什么
git checkout -- configs/niri/          # 丢弃未提交的改动
git diff HEAD~1 -- configs/niri/       # 或者对比上一个提交
`@

**⑤ 启动 MangoWM 恢复图形界面**

在 TTY 里直接启动：

`@bash
mango
`@

如果 `mango` 起不来，带上 dbus 会话再试：

`@bash
dbus-run-session mango
`@

如果你用的是登录管理器（ly / sddm / greetd），也可以重启它再选 Mango：

`@bash
systemctl restart display-manager
`@

**⑥ 在 MangoWM 里把 Niri 修好**

Mango 起来后按 `SUPER + Enter` 打开 Kitty：

`@bash
micro ~/.config/niri/config.kdl   # 或 nano / geany
niri validate -c ~/.config/niri/config.kdl
`@

**⑦ 切回 Niri**

- 按 `Ctrl + Alt + F1`（或原来图形界面对应的 TTY）回到 Niri 会话
- 若 Niri 进程已经死了，用登录管理器重新登录，或在 TTY 里直接敲 `niri`

**⑧ 还是不行？终极方案**

`@bash
# 重装 Niri
sudo pacman -S niri --noconfirm

# 确认 GPU 驱动正常（Intel / AMD / NVIDIA 按自己的硬件看）
lspci -k | grep -EA3 'VGA|3D'

# 用 MangoWM 顶几天，把 Niri 配置彻底重写
`@

### 提前给自己上保险

- 这台机器上**同时装好 Niri 和 MangoWM**，两条路走，别把鸡蛋放一个篮子。
- 每次改 `config.kdl` 之前先 `git commit`，出事一条 `git checkout` 回到解放前。
- 改完立刻验证：`niri validate -c ~/.config/niri/config.kdl`，语法没问题再重启 Niri。
- 记下这个仓库地址，手机上也存一份——黑屏时你还能查这份 README。

---

## 🔐 安全说明

- 仓库内**不含任何私钥、密码、token、cookie**；提交前已做敏感信息扫描。
- `.gitignore` 屏蔽了 `.ssh/`、`*.pem`、`*.key`、`hosts.yml`、`.env`、`*.log` 等常见泄漏源。
- `geany/session.conf`（含最近打开文件的绝对路径）与 `micro/buffers`（未保存的编辑缓冲）**默认不入库**。
- GitHub 凭据由 `gh auth login` 管理，仓库里不保存任何登录信息。

要在公开仓库里加新配置，提交前建议自查一遍：

`@bash
grep -rInE "(api[_-]?key|token|secret|password|PRIVATE KEY)" configs/
`@

---

## 🛠 日常使用

`@bash
# 配置改错了，撤销
cd ~/dotfiles && git checkout -- configs/waybar/

# 拉取最新配置
cd ~/dotfiles && git pull

# 热重载 Niri（不用重启会话）
niri msg action load-config-file

# 重启 Waybar
pkill -x waybar; waybar &

# 检查软链接是否正常
ls -l ~/.config/niri ~/.config/waybar ~/.zshrc
`@

### 换机器时的注意事项

配置里存在写死的绝对路径（例如壁纸 `/home/usernameless/Pictures/...`、脚本路径），换用户名后需要批量替换：

`@bash
cd ~/dotfiles
grep -rl "/home/usernameless" configs/ | xargs sed -i "s|/home/usernameless|$HOME|g"
`@

`install.sh` 检测到 `$HOME` 不是 `/home/usernameless` 时会主动提醒你这件事。

---

## 📄 说明

个人配置仓库，欢迎参考和抄作业。配置按「够用就好」的原则维护，不追求花哨。
不提供任何担保——照着改之前，记得先备份。

---

<sub>Made with 🖤 on Arch Linux · Niri + Waybar + Kitty</sub>
