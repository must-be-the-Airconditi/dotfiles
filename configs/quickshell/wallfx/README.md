# wallfx（移植自 diegoMalagrida/pocket-dots）

壁纸转场：Quickshell 画一层 shader 覆盖层，awww 在底下切换。

- `WallpaperFx.qml` — 转场层 + IPC（`qs -c wallfx ipc call wallfx play …`）
- `shaders/wallfx.frag` — 原始 GLSL；`.qsb` 用系统 qsb 编译：
  `/usr/lib/qt6/bin/qsb --qt6 -o shaders/wallfx.v15.frag.qsb shaders/wallfx.frag`
- `~/.local/bin/wallfx` — 生成"什么时候到"的地图
- `~/.local/bin/wallpaper-next` — 带路径直接换；不带参数开选择器
- `~/.local/bin/wallpaper-pick` — 起 quickshell 并打开 `WallpaperPicker.qml`（niri: Mod+Shift+W）
- `WallpaperPicker.qml` — 缩略图网格选择器（方向键/Enter/Esc，选完 12s 无操作自动退出）
- 壁纸目录：`~/Pictures/wallpapers`

## 相对原版的改动

- 去掉 `Colors`（pywal）依赖，改用固定 Catppuccin Mocha 调色板取 ember / ink。
- **只保留 contagion（像素殖民地）转场**：outline（角色描边）需要 rembg + onnxruntime + BirefNet 模型，
  在这台 i5-2400S / 3.8 GB 上内存占用 ~1 GB，已被移除以避免吃内存；`wallfx elige` 现在永远返回 contagion。
  如果以后想要 outline，`wallfx instalar` 需要 Python 3.12（系统 3.14 不兼容 onnxruntime 轮子），
  并且要把 venv 的 certifi 追加 DevSidecar CA 才能从 GitHub 下载模型。
- 其余逻辑原样：加载 → 淡入 → awww 瞬间切换 → 转场结束 → 淡出；2.5s 看门狗失败回落普通 fade。
