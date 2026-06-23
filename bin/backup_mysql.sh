#!/bin/bash
# MySQL全量备份脚本

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# 数据库配置（优先读取 ~/.my.cnf，此处为备选）
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-}"
BACKUP_DIR="${BASE_DIR}/backup"
RETENTION_DAYS=7
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${BASE_DIR}/logs/backup.log"

mkdir -p "${BACKUP_DIR}" "${BASE_DIR}/logs"

# 构建 mysqldump 参数
DUMP_ARGS="-u${DB_USER} --all-databases --single-transaction"
if [ -n "${DB_PASSWORD}" ]; then
    DUMP_ARGS="${DUMP_ARGS} -p${DB_PASSWORD}"
fi

# 备份所有数据库
set -o pipefail
if mysqldump ${DUMP_ARGS} | gzip > "${BACKUP_DIR}/mysql_all_${DATE}.sql.gz"; then
    if [ -s "${BACKUP_DIR}/mysql_all_${DATE}.sql.gz" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] 备份成功：mysql_all_${DATE}.sql.gz ($(du -h "${BACKUP_DIR}/mysql_all_${DATE}.sql.gz" | cut -f1))" >> "${LOG_FILE}"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] 备份文件为空！" >> "${LOG_FILE}"
        exit 1
    fi
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] 备份失败！" >> "${LOG_FILE}"
    exit 1
fi

# 清理过期备份
deleted=$(find "${BACKUP_DIR}" -name "mysql_all_*.sql.gz" -mtime +${RETENTION_DAYS} -delete -print | wc -l)
if [ "${deleted}" -gt 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] 已清理 ${deleted} 个过期备份" >> "${LOG_FILE}"
fi
