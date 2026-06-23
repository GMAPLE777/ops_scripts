#!/bin/bash
# 批量执行命令脚本

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

HOST_FILE="${BASE_DIR}/conf/hosts.list"
CMD="$1"

if [ -z "${CMD}" ]; then
    echo "用法：$0 \"要执行的命令\""
    exit 1
fi

if [ ! -f "${HOST_FILE}" ]; then
    echo "[ERROR] 主机列表文件不存在: ${HOST_FILE}" >&2
    exit 1
fi

total=0
success=0
fail=0

while IFS= read -r host; do
    # 跳过空行和注释
    [[ -z "${host}" || "${host}" =~ ^# ]] && continue
    ((++total))

    echo "===== 在 ${host} 上执行命令 ====="
    if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"${host}" "${CMD}"; then
        ((++success))
    else
        echo "[ERROR] ${host} 执行失败"
        ((++fail))
    fi
    echo ""
done < "${HOST_FILE}"

echo "===== 执行汇总 ====="
echo "总计：${total} 台，成功：${success} 台，失败：${fail} 台"
