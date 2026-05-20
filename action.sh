#!/system/bin/sh
# action.sh - KSU模块Action按钮脚本，显示当前状态
MODDIR=${0%/*}
CONFDIR="$MODDIR/config"

echo "=============================="
echo "  HyperThermal 动态温控状态"
echo "=============================="
echo ""

# 设备信息
if [ -f "$CONFDIR/runtime.json" ]; then
    echo "设备: $(cat $CONFDIR/runtime.json | sed 's/.*model":"//;s/".*//')"
    echo "平台: $(cat $CONFDIR/runtime.json | sed 's/.*platform":"//;s/".*//')"
    echo "温控进程: $(cat $CONFDIR/runtime.json | sed 's/.*thermal_daemon":"//;s/".*//')"
fi
echo ""

# 电池状态
TEMP=$(cat /sys/class/power_supply/battery/temp 2>/dev/null)
CURRENT=$(cat /sys/class/power_supply/battery/current_now 2>/dev/null)
CAPACITY=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null)
STATUS=$(cat /sys/class/power_supply/battery/status 2>/dev/null)
echo "电池温度: $((TEMP/10)).$((TEMP%10))°C"
echo "充电电流: $((CURRENT/1000))mA"
echo "电量: ${CAPACITY}%"
echo "状态: $STATUS"
echo ""

# 当前模式
MODE=$(cat "$CONFDIR/current_mode" 2>/dev/null)
echo "当前温控模式: ${MODE:-未知}"
echo ""

# 旁路状态
BYPASS=$(cat "$CONFDIR/bypass_active" 2>/dev/null)
[ "$BYPASS" = "1" ] && echo "旁路供电: 开启" || echo "旁路供电: 关闭"
echo ""
echo "提示: 请在KSU管理器中点击'设置'图标打开WebUI进行配置"
