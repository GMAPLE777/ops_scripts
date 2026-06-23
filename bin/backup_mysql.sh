#!/bin/bash
# MySQL全量备份脚本

# 数据库配置
DB_USER="root"
DB_PASSWORD="your_password"
BACKUP_DIR="/home/gmaple777/projects/OAM/ops_scripts/backup"
RETENTION_DAYS=7
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/home/gmaple777/projects/OAM/ops_scripts/logs/backup.log"

mkdir -p $BACKUP_DIR

# 备份所有数据库
mysqldump -u$DB_USER -p$DB_PASSWORD --all-databases --single-transaction | gzip > $BACKUP_DIR/mysql_all_$DATE.sql.gz

# 校验备份文件
if [ $? -eq 0 ] && [ -s $BACKUP_DIR/mysql_all_$DATE.sql.gz ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 备份成功：mysql_all_$DATE.sql.gz" >> $LOG_FILE
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 备份失败！" >> $LOG_FILE
fi

# 清理7天前的备份文件
find $BACKUP_DIR -name "mysql_all_*.sql.gz" -mtime +$RETENTION_DAYS -delete
