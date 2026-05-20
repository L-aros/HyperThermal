# AGENT.md

## 角色

你是 HyperThermal 模块的开发助手，负责维护和迭代这个 KernelSU 动态温控模块。

## 项目上下文

- 目标设备：小米/红米手机，HyperOS 1.x/2.x/3.x，KernelSU root
- 温控进程：`mi_thermald`，通过 `/data/vendor/thermal/config/` 读取云温控配置
- WebUI：KSU Manager 内置 WebView 加载 `webroot/index.html`，通过 `ksu.exec()` 执行 shell 命令

## 工作流程

1. 修改代码后，通过 adb 推送到设备 `/data/adb/modules/HyperThermal/` 热更新
2. 重启 thermal_core 进程验证（`pkill -f thermal_core.sh` 后自动重启，或用 restart.sh）
3. 用 `charge_monitor.sh` 监控充电状态验证功能
4. 确认无误后 `git commit && git push`
5. 发版时打包 zip 并通过 GitHub API 创建 Release

## 关键约束

- **不要用 heredoc 写文件**：`ksu.exec()` 不支持多行 heredoc，用 `printf` 逐行写入
- **不要用 `eval` 解析 JSON**：会被特殊字符注入，用 `grep + sed` 逐字段提取
- **不要依赖 `program_data()` 触发机制**：HyperOS 3.0 上 `mvt.conf` 触发已失效，必须 `stop/start mi_thermald`
- **写入温控文件后必须恢复 SELinux context**：`chown root:system + chcon u:object_r:thermal_data_file:s0`
- **mi_thermald 重启后必须恢复 `wired_chg_curr`**：否则充电电流会被重置到低值
- **配置文件写入必须原子化**：先写 `.tmp` 再 `mv`，防止 thermal_core 读到半写状态
- **充电状态防抖**：mi_thermald 重启瞬间充电状态会短暂中断，跳过该轮不切换模式
- **zip 路径必须用正斜杠**：PowerShell `Compress-Archive` 会用反斜杠，Android 无法解压

## 设备信息

- 机型：Xiaomi 17 Pro Max (2509FPN0BC)
- 平台：canoe
- 系统：HyperOS 3.0 (OS3.0.306.0.WPBCNXM)
- 充电：120W 有线快充
- 充电电流节点：`/sys/class/xm_power/charger/charger_thermal/wired_chg_curr`（max 22000000）
- 电压节点：`/sys/class/power_supply/battery/voltage_now`
- 温控进程：mi_thermald

## 代码风格

- Shell：POSIX 兼容，使用 `local` 变量，函数名用下划线分隔
- WebUI：单文件 HTML，内联 CSS/JS，HyperOS/Miuix 设计风格
- Git：conventional commits（feat/fix/ui/docs）
