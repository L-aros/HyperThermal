# CLAUDE.md

## 项目概述

HyperThermal 是一个适配 HyperOS/MIUI 全版本的 KernelSU 动态温控模块，通过替换 `/data/vendor/thermal/config/` 下的云温控文件并重启 `mi_thermald` 进程来控制充电温控策略。

## 技术栈

- Shell 脚本（`/system/bin/sh`，Android mksh）
- HTML/CSS/JS（KSU WebUI，运行在 WebView 中）
- KSU 模块框架（Magisk 兼容）

## 关键文件

- `service.sh` — 开机启动，检测环境，启动 thermal_core.sh
- `thermal_core.sh` — 核心逻辑，3秒轮询，决策温控模式
- `webroot/index.html` — WebUI 界面（HyperOS 风格）
- `t_blank` / `t_bypass_0` / `t_bypass_1` / `t_map` — 二进制温控配置文件
- `thermal/1~5/thermal-scene.conf` — 各档位温控文件（加密格式）
- `config/settings.json` — 用户配置（WebUI 读写）

## 开发注意事项

- Shell 脚本必须使用 LF 换行符（`.gitattributes` 已配置）
- `mi_thermald` 重启后会重置 `wired_chg_curr`，需要立即恢复
- 充电状态在 mi_thermald 重启瞬间会短暂中断，需要防抖
- WebUI 保存配置使用临时文件 + `mv` 原子替换，避免竞态
- `json_get()` 函数需要 `settings.json` 非空才能工作（`[ -s file ]` 检查）
- 温控文件是加密二进制格式，无法直接编辑内容
- zip 打包必须使用正斜杠路径（Android unzip 不识别反斜杠）

## 构建

```powershell
# PowerShell 打包（确保正斜杠路径）
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$src = "C:\Users\DPC\HyperThermal"
$zip = [System.IO.Compression.ZipFile]::Open("HyperThermal.zip", "Create")
Get-ChildItem -Path $src -Recurse -File | Where-Object { $_.FullName -notmatch '\\.git\\' } | ForEach-Object {
    $rel = $_.FullName.Substring($src.Length + 1).Replace('\', '/')
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, $rel, "Optimal") | Out-Null
}
$zip.Dispose()
```

## 测试

```bash
# 推送到设备
adb push webroot/index.html /data/local/tmp/
adb push thermal_core.sh /data/local/tmp/
adb shell "su -c 'cp /data/local/tmp/index.html /data/adb/modules/HyperThermal/webroot/ && cp /data/local/tmp/thermal_core.sh /data/adb/modules/HyperThermal/ && chmod 755 /data/adb/modules/HyperThermal/thermal_core.sh'"

# 重启 thermal_core 进程
adb push restart.sh /data/local/tmp/
adb shell "su -c 'sh /data/local/tmp/restart.sh'"

# 充电监控
adb shell "su -c 'timeout 60 sh /data/local/tmp/charge_monitor.sh'"
```
