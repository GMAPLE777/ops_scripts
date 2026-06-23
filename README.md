# 服务器自动化运维脚本工具箱

## 项目简介

替代运维日常人工重复操作，实现服务器巡检、日志分析、数据备份、批量管理四大场景的自动化。

## 目录结构

```
ops_scripts/
├── bin/                    # 可执行脚本
│   ├── check_system.sh     # 系统巡检脚本
│   ├── analyze_nginx_log.sh # Nginx日志分析脚本
│   ├── backup_mysql.sh     # MySQL备份脚本
│   └── batch_cmd.sh        # 批量执行脚本
├── conf/                   # 配置文件
│   ├── hosts.list          # 主机列表
│   └── crontab.conf        # 定时任务配置
├── logs/                   # 运行日志
└── backup/                 # MySQL备份文件
```

## 使用方法

### 1. 系统巡检

```bash
bash bin/check_system.sh
```

检测 CPU、内存、磁盘、端口、进程状态，结果输出到 `logs/` 目录。

### 2. Nginx 日志分析

```bash
bash bin/analyze_nginx_log.sh
```

分析 `/var/log/nginx/access.log`，输出 TOP10 IP、状态码分布、TOP10 接口。

### 3. MySQL 备份

```bash
bash bin/backup_mysql.sh
```

全量备份 MySQL 数据库，自动压缩并清理 7 天前的备份。

**注意**: 修改脚本中的 `DB_USER` 和 `DB_PASSWORD` 为实际数据库凭据。

### 4. 批量执行命令

```bash
bash bin/batch_cmd.sh "hostname"
```

在 `conf/hosts.list` 中的所有主机上执行指定命令。

**前置条件**: 配置 SSH 免密登录。

## 定时任务部署

```bash
# 查看定时任务配置
cat conf/crontab.conf

# 部署定时任务
crontab -e
# 粘贴 crontab.conf 中的内容
```

## 配置说明

### 告警阈值（check_system.sh）

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| CPU_WARN | 80 | CPU 使用率告警阈值 |
| MEM_WARN | 80 | 内存使用率告警阈值 |
| DISK_WARN | 85 | 磁盘使用率告警阈值 |
| CHECK_PORTS | 80, 3306, 9090 | 检测端口列表 |
| CHECK_PROCESSES | nginx, mysqld | 检测进程列表 |

### 备份配置（backup_mysql.sh）

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| DB_USER | root | 数据库用户名 |
| DB_PASSWORD | your_password | 数据库密码 |
| RETENTION_DAYS | 7 | 备份保留天数 |

## 常见问题

1. **脚本执行报错**: 检查路径是否正确、命令是否安装
2. **MySQL 备份失败**: 确认 mysqldump 可用、账号密码正确
3. **定时任务不执行**: 检查 crond 服务状态、脚本权限
4. **SSH 免密不生效**: 检查 `.ssh/authorized_keys` 权限（600）
