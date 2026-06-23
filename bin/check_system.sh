#!/bin/bash
# 系统巡检脚本：检测CPU、内存、磁盘、端口、进程

set -euo pipefail

# 脚本目录自适应
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# 配置项
DISK_WARN=85
CPU_WARN=80
MEM_WARN=80
CHECK_PORTS=("80" "3306" "9090")
CHECK_PROCESSES=("nginx" "mysqld")
LOG_FILE="${BASE_DIR}/logs/check_system_$(date +%Y%m%d).log"

mkdir -p "${BASE_DIR}/logs"

# 告警计数
ALERT_COUNT=0

# 日志函数
log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${level}] $*" | tee -a "${LOG_FILE}"
}

log "INFO" "===== 开始系统巡检 ====="

# 1. CPU使用率检测
if command -v mpstat &>/dev/null; then
    cpu_usage=$(mpstat 1 1 | awk '/Average/ {print 100 - $NF}' | cut -d. -f1)
else
    cpu_usage=$(vmstat 1 2 | tail -1 | awk '{print 100 - $15}')
fi

if [ -n "${cpu_usage}" ] && [ "${cpu_usage}" -gt "${CPU_WARN}" ] 2>/dev/null; then
    log "WARN" "CPU 使用率：${cpu_usage}%（超过阈值 ${CPU_WARN}%）"
    ((++ALERT_COUNT))
else
    log "INFO" "CPU 使用率：${cpu_usage}%"
fi

# 2. 内存使用率检测
mem_total=$(free -m | awk 'NR==2{print $2}')
mem_used=$(free -m | awk 'NR==2{print $3}')
mem_usage=$((mem_used * 100 / mem_total))

if [ "${mem_usage}" -gt "${MEM_WARN}" ]; then
    log "WARN" "内存使用率：${mem_usage}%（总 ${mem_total}M / 已用 ${mem_used}M，超过阈值 ${MEM_WARN}%）"
    ((++ALERT_COUNT))
else
    log "INFO" "内存使用率：${mem_usage}%（总 ${mem_total}M / 已用 ${mem_used}M）"
fi

# 3. 磁盘使用率检测
log "INFO" "磁盘使用率检测："
while read -r rate mount; do
    num=${rate%\%}
    if [ "${num}" -gt "${DISK_WARN}" ] 2>/dev/null; then
        log "WARN" "  ${mount} : ${rate}（超过阈值 ${DISK_WARN}%）"
        ((++ALERT_COUNT))
    else
        log "INFO" "  ${mount} : ${rate}"
    fi
done < <(df -h | grep -v tmpfs | grep -v loop | awk 'NR>1{print $5 " " $6}')

# 4. 端口存活检测
log "INFO" "端口存活检测："
for port in "${CHECK_PORTS[@]}"; do
    if ss -tuln | grep -q ":${port} "; then
        log "INFO" "  端口 ${port} ：正常监听"
    else
        log "WARN" "  端口 ${port} ：未监听"
        ((++ALERT_COUNT))
    fi
done

# 5. 进程存活检测
log "INFO" "进程存活检测："
for proc in "${CHECK_PROCESSES[@]}"; do
    if pgrep -x "${proc}" > /dev/null; then
        log "INFO" "  进程 ${proc} ：运行中"
    else
        log "WARN" "  进程 ${proc} ：未运行"
        ((++ALERT_COUNT))
    fi
done

log "INFO" "===== 系统巡检结束（告警数：${ALERT_COUNT}）====="
