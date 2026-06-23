#!/bin/bash
# Nginx访问日志分析脚本

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

LOG_PATH="/var/log/nginx/access.log"
OUTPUT_FILE="${BASE_DIR}/logs/nginx_analyze_$(date +%Y%m%d).log"

mkdir -p "${BASE_DIR}/logs"

if [ ! -f "${LOG_PATH}" ]; then
    echo "[ERROR] Nginx 日志文件不存在: ${LOG_PATH}" >&2
    exit 1
fi

{
    echo "===== Nginx 访问日志分析报告 ====="
    echo "生成时间：$(date '+%Y-%m-%d %H:%M:%S')"
    echo "日志文件：${LOG_PATH}"
    echo ""

    echo "1. 总请求量："
    wc -l "${LOG_PATH}" | awk '{print "  总请求数："$1}'

    echo ""
    echo "2. 访问量 TOP10 IP："
    awk '{print $1}' "${LOG_PATH}" | sort | uniq -c | sort -nr | head -10 | awk '{print "  第"NR"名："$2"，请求"$1"次"}'

    echo ""
    echo "3. HTTP状态码分布："
    awk '{print $9}' "${LOG_PATH}" | sort | uniq -c | sort -nr | awk '{print "  状态码"$2"："$1"次"}'

    echo ""
    echo "4. 请求量 TOP10 接口："
    awk '{print $7}' "${LOG_PATH}" | sort | uniq -c | sort -nr | head -10 | awk '{print "  第"NR"名："$2"，请求"$1"次"}'

    echo "===== 分析完成 ====="
} > "${OUTPUT_FILE}"

cat "${OUTPUT_FILE}"
