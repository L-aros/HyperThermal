#!/system/bin/sh
# customize.sh - 由Magisk/KSU安装框架自动调用，MODPATH已由框架设置好

ui_print "=============================="
ui_print "  HyperThermal - 动态温控"
ui_print "  适配 HyperOS 全版本"
ui_print "=============================="

# 检测温控进程
if which mi_thermald >/dev/null 2>&1; then
    ui_print "- 检测到 mi_thermald"
elif which thermal-engine >/dev/null 2>&1; then
    ui_print "- 检测到 thermal-engine"
else
    ui_print "! 未检测到温控进程，模块可能无法工作"
fi

# 检测系统版本
OS_VER=$(getprop ro.mi.os.version.incremental 2>/dev/null)
if [ -n "$OS_VER" ]; then
    ui_print "- HyperOS: $OS_VER"
else
    ui_print "- MIUI: $(getprop ro.miui.ui.version.name 2>/dev/null)"
fi

# 初始化config目录和默认配置
mkdir -p "$MODPATH/config"
cp "$MODPATH/default_settings.json" "$MODPATH/config/settings.json"

# 从旧模块迁移游戏列表
OLD_CONF="/data/adb/modules/MiuiVariableThermal/config.conf"
if [ -f "$OLD_CONF" ]; then
    OLD_APPS=$(grep '^app_list=' "$OLD_CONF" | sed 's/app_list=//')
    if [ -n "$OLD_APPS" ]; then
        ui_print "- 从旧模块迁移游戏列表"
        sed -i "s|\"game_apps\":\"[^\"]*\"|\"game_apps\":\"$OLD_APPS\"|" "$MODPATH/config/settings.json"
    fi
fi

# 设置权限
# 脚本文件：0755，其他文件：0644，目录：0755
set_perm_recursive "$MODPATH" root root 0755 0644
# config目录需要可写（service.sh运行时写入）
set_perm "$MODPATH/config" root root 0777
set_perm "$MODPATH/service.sh" root root 0755
set_perm "$MODPATH/thermal_core.sh" root root 0755
set_perm "$MODPATH/action.sh" root root 0755
set_perm "$MODPATH/uninstall.sh" root root 0755

ui_print "- 安装完成，重启后生效"
ui_print "- 在KSU管理器中点击模块设置图标打开WebUI"
