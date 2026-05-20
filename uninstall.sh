#!/system/bin/sh
# 卸载时恢复系统默认温控
chattr -R -i -a /data/vendor/thermal 2>/dev/null
rm -rf /data/vendor/thermal/config/*

# 重启温控进程
if which mi_thermald >/dev/null 2>&1; then
    stop mi_thermald; start mi_thermald
elif which thermal-engine >/dev/null 2>&1; then
    stop thermal-engine; start thermal-engine
fi
