#!/bin/bash
# 批量执行命令脚本

HOST_FILE="/home/gmaple777/projects/OAM/ops_scripts/conf/hosts.list"
CMD="$1"

if [ -z "$CMD" ]; then
    echo "用法：./batch_cmd.sh \"要执行的命令\""
    exit 1
fi

if [ ! -f "$HOST_FILE" ]; then
    echo "错误：主机列表文件不存在 $HOST_FILE"
    exit 1
fi

for host in $(cat $HOST_FILE); do
    echo "===== 在 $host 上执行命令 ====="
    ssh root@$host "$CMD"
    echo ""
done
