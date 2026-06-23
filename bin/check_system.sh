#!/bin/bash
# 系统巡检脚本：检测CPU、内存、磁盘、端口、进程

# 配置项
ALERT_EMAIL="admin@example.com"
DISK_WARN=85
CPU_WARN=80
MEM_WARN=80
CHECK_PORTS=("80" "3306" "9090")
CHECK_PROCESSES=("nginx" "mysqld")
LOG_FILE="/home/gmaple777/projects/OAM/ops_scripts/logs/check_system_$(date +%Y%m%d).log"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

log "===== 开始系统巡检 ====="

# 1. CPU使用率检测
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
log "CPU 使用率：${cpu_usage}%"
[ $cpu_usage -gt $CPU_WARN ] && log "【告警】CPU 使用率超过阈值 ${CPU_WARN}%"

# 2. 内存使用率检测
mem_total=$(free -m | awk 'NR==2{print $2}')
mem_used=$(free -m | awk 'NR==2{print $3}')
mem_usage=$((mem_used * 100 / mem_total))
log "内存使用率：${mem_usage}%（总 ${mem_total}M / 已用 ${mem_used}M）"
[ $mem_usage -gt $MEM_WARN ] && log "【告警】内存使用率超过阈值 ${MEM_WARN}%"

# 3. 磁盘使用率检测
log "磁盘使用率检测："
df -h | grep -v tmpfs | grep -v loop | awk 'NR>1{print $5 " " $6}' | while read rate mount; do
    num=${rate%\%}
    log "  ${mount} : ${rate}"
    [ $num -gt $DISK_WARN ] && log "  【告警】${mount} 磁盘使用率超过阈值 ${DISK_WARN}%"
done

# 4. 端口存活检测
log "端口存活检测："
for port in "${CHECK_PORTS[@]}"; do
    ss -tuln | grep -q ":$port "
    if [ $? -eq 0 ]; then
        log "  端口 $port ：正常监听"
    else
        log "  【告警】端口 $port 未监听"
    fi
done

# 5. 进程存活检测
log "进程存活检测："
for proc in "${CHECK_PROCESSES[@]}"; do
    pgrep -x "$proc" > /dev/null
    if [ $? -eq 0 ]; then
        log "  进程 $proc ：运行中"
    else
        log "  【告警】进程 $proc 未运行"
    fi
done

log "===== 系统巡检结束 ====="
