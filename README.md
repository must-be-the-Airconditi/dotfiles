# Arch Linux Dotfiles

> Niri 主力 · MangoWM 兜底 · Waybar · Kitty + Zsh
> 一个 `git clone` 就能跑起来的 Arch Wayland 桌面配置。

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat-square&logo=arch-linux&logoColor=white)
![Wayland](https://img.shields.io/badge/Wayland-FFBC00?style=flat-square&logo=wayland&logoColor=black)
![Shell](https://img.shields.io/badge/Shell-Zsh-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)
![WM](https://img.shields.io/badge/WM-Niri_%2F_MangoWM-89b4fa?style=flat-square)

## 概览

| 用途 | 软件 | 备注 |
| :--- | :--- | :--- |
| 窗口管理器（主力） | **Niri** | 滚动平铺、圆角毛玻璃、平滑动画 |
| 窗口管理器（备用） | **MangoWM** | 轻量 dwm 风格，黑屏时用来救场 |
| 状态栏 | **Waybar** | 天气 / 音量 / 亮度 / 网络 / 托盘 / 电源菜单 |
| 启动器 | **Fuzzel** | Wayland 原生启动器 |
| 终端 | **Kitty** | GPU 加速 + Catppuccin 配色 |
| Shell | **Zsh** | Oh My Zsh + Powerlevel10k + autosuggestions |
| 通知 / 壁纸 | **Mako** / **Swaybg** | 毛玻璃通知；壁纸由你自己选（仓库不附带图片） |
| 编辑器 / IDE | **nano / micro / Geany / PyCharm** | 终端用 nano、micro，图形界面用 Geany、PyCharm |
| Python 环境 | **direnv** | 进目录自动加载 `.envrc` 虚拟环境 |

## 目录结构

```
dotfiles/
├── configs/                 # 与 ~/.config/ 一一对应
│   ├── niri/                # config.kdl + screenshot.sh
│   ├── mango/               # config.conf
│   ├── waybar/              # config.jsonc / style.css / scripts/
│   ├── micro/               # bindings.json
│   ├── geany/               # geany.conf / keybindings.conf / 配色
│   └── kitty/               # kitty.conf + 主题
├── home/
│   └── zshrc                # → ~/.zshrc
├── bin/
│   └── wallpaper.sh         # → ~/.local/bin/wallpaper（选壁纸 / 开机拉起）
├── install.sh               # 装包 → 备份 → 软链接
├── .gitignore
└── README.md
```

映射规则三条：**`configs/X` → `~/.config/X`**，**`home/X` → `~/X`**，**`bin/X` → `~/.local/bin/X`**。
新增一个应用 = 把配置放进对应位置，再在 `install.sh` 的 `LINKS` 表里加一行。

## 安装

前置条件：Arch 系发行版、能联网、普通用户有 `sudo` 权限。依赖全在官方仓库，暂不需要 AUR。

```bash
git clone https://github.com/must-be-the-Airconditi/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

第一次跑建议先加 `--dry-run` 预览，它会列出所有将要执行的动作而不碰任何文件。

| 参数 | 作用 |
| :--- | :--- |
| （无） | 装包 + 备份 + 软链接，全套 |
| `--skip-packages` | 跳过装包，只做备份和软链接 |
| `--dry-run` | 只打印计划，不修改任何文件 |
| `-h` / `--help` | 查看帮助 |

脚本六步：检查环境 → `pacman -S --needed` 装齐依赖 → 缺 Oh My Zsh / Powerlevel10k 时自动克隆 → 把已有配置改名为 `xxx.bak-YYYYmmdd-HHMMSS` → `ln -sfn` 建软链接 → 给脚本加执行位。

> 安全设计：全程只做 `mv` 备份和 `ln` 软链接，**不覆盖、不删除**你已有的任何文件。

## 快捷键

**Niri（主力）**

| 快捷键 | 功能 |
| :--- | :--- |
| `Mod + T` | 打开 Kitty |
| `Mod + D` | 打开 Fuzzel |
| `Mod + Q` | 关闭窗口 |
| `Mod + F` / `Mod + Shift + F` | 当前列最大化 / 切换浮动 |
| `Mod + Shift + S` | 区域截图（grim + slurp + satty） |
| `Mod + ← / →` | 切换列焦点 |
| `Mod + ↑ / ↓` | 切换窗口焦点 |
| `Mod + 1 / 2 / 3` | 切换工作区 |

**MangoWM（备用）**

| 快捷键 | 功能 |
| :--- | :--- |
| `SUPER + Enter` / `SUPER + T` | 打开 Kitty |
| `SUPER + D` | 打开 Fuzzel |
| `SUPER + Q` | 关闭窗口 |
| `SUPER + F` | 切换全屏 |
| `SUPER + Shift + R` | 重新加载配置 |
| `SUPER + Shift + E` | 退出 MangoWM |

## 紧急救援：Niri 黑屏

保留 MangoWM 的唯一原因就是这一节——配置写崩、驱动抽风时，你还有第二个图形界面可用。

| 现象 | 大概率原因 | 去哪一步 |
| :--- | :--- | :--- |
| 黑屏只有鼠标指针 | `config.kdl` 语法错误 | 第 3 步回滚配置 |
| 壁纸在、Waybar 不见了 | Waybar 进程崩了 | 第 4 步起 Mango，再 `pkill -x waybar; waybar &` |
| 快捷键全无响应 | 会话 / 驱动卡死 | 第 4 步切 Mango |

**① 先等 10 秒。** Niri 偶尔只是动画卡住，30 秒没动静再动手。

**② 切到 TTY。** 按 `Ctrl + Alt + F2`。

> `F1`–`F6` 逐个试，部分笔记本需要配合 `Fn`。看到 `login:` 就对了，输用户名和密码（密码不回显，正常）。

**③ 定位问题：**

```bash
journalctl -b -p err --no-pager | tail -50        # 最近的错误日志
niri validate -c ~/.config/niri/config.kdl        # 90% 的黑屏是配置语法错
pgrep -a niri                                     # 进程还活着吗
```

`niri validate` 报错就是配置问题，直接回滚：

```bash
cd ~/dotfiles
git log --oneline -5                 # 最近改了什么
git checkout -- configs/niri/        # 丢弃未提交的改动
```

**④ 恢复图形界面：**

```bash
mango                       # 直接起 MangoWM
dbus-run-session mango      # 起不来时带上 dbus 会话
systemctl restart display-manager   # 或者重启登录管理器，再选 Mango
```

进 Mango 后按 `SUPER + Enter` 开终端，用 `micro ~/.config/niri/config.kdl` 改配置，改完 `niri validate` 验证。

**⑤ 切回 Niri。** 按 `Ctrl + Alt + F1` 回到原会话；Niri 进程已死就在 TTY 里直接敲 `niri`，或重启登录管理器重新登录。

**⑥ 还是不行：** `sudo pacman -S niri` 重装；`lspci -k | grep -EA3 'VGA|3D'` 确认显卡驱动正常；实在搞不定就先用 MangoWM 顶几天，把 Niri 配置推倒重写。

平时做的三件事：改 `config.kdl` 前先提交、改完立刻 `niri validate`、把仓库地址存在手机上（黑屏时还得靠它）。

## 日常维护

```bash
cd ~/dotfiles && git pull              # 拉取最新配置
niri msg action load-config-file       # 热重载 Niri
pkill -x waybar; waybar &              # 重启 Waybar
ls -l ~/.config/niri ~/.zshrc          # 检查软链接是否正常
wallpaper                              # 换壁纸（见下）
```

**壁纸自己选，仓库不替你决定。** 仓库里不放图片文件——每个人的喜好不一样。开机时 `wallpaper` 按这个顺序找：

1. `WALLPAPER` 环境变量（临时覆盖）
2. `~/.config/dotfiles/wallpaper` 里记着你上次选的图
3. `~/Pictures` 下排第一的图片（还没选过时的临时顶替）
4. 主题底色 `#1e1e2e`（一张图都没有也不会黑屏）

**装完第一件事：挑一张。** 把喜欢的图放进 `~/Pictures`，然后：

```bash
wallpaper pick            # fuzzel 里选一张，选择会记住
wallpaper set ~/图/a.jpg   # 也可以直接指定路径
wallpaper list            # 看候选，● 是当前选中的
wallpaper current         # 确认现在跑的是哪张
wallpaper -m stretch      # 换缩放模式：fill / fit / stretch / center / tile
```

你的选择存在 `~/.config/dotfiles/wallpaper`（一行绝对路径），不进仓库，所以换人换机器互不影响。

**任意用户名都能装。** 配置里没有任何写死的家目录路径——壁纸、脚本、PATH 全部用 `$HOME/...` 或 `~/...`，换账号、换机器都直接可用。

`install.sh` 启动时会自检：一旦发现新加的配置里出现 `/home/<用户名>` 这类写法，会列出来提醒你改成 `$HOME`。

## 安全

- 仓库内**不含任何私钥、密码、token**；提交前做过敏感信息扫描。
- `.gitignore` 屏蔽了 `.ssh/`、`*.pem`、`*.key`、`hosts.yml`、`.env`、`*.log`、`*.bak*` 等泄漏源。
- `geany/session.conf`（含最近文件路径）与 `micro/buffers`（未保存的编辑缓冲）默认不入库。
- GitHub 凭据交给 `gh auth login` 管理，仓库里不存任何登录信息。

往公开仓库加新配置前，自查一遍：

```bash
grep -rInE "(api[_-]?key|token|secret|password|PRIVATE KEY)" configs/ home/
```

## 说明

个人配置，欢迎参考和抄作业。按「够用就好」维护，不追求花哨；不提供任何担保——照着改之前先备份。

<sub>Made with 🖤 on Arch Linux · Niri + Waybar + Kitty</sub>
