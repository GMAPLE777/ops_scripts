#!/bin/bash
# Nginx访问日志分析脚本

LOG_PATH="/var/log/nginx/access.log"
OUTPUT_FILE="/home/gmaple777/projects/OAM/ops_scripts/logs/nginx_analyze_$(date +%Y%m%d).log"

echo "===== Nginx 访问日志分析报告 =====" > $OUTPUT_FILE
echo "生成时间：$(date '+%Y-%m-%d %H:%M:%S')" >> $OUTPUT_FILE
echo "日志文件：$LOG_PATH" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

echo "1. 总请求量：" >> $OUTPUT_FILE
wc -l $LOG_PATH | awk '{print "  总请求数："$1}' >> $OUTPUT_FILE

echo "" >> $OUTPUT_FILE
echo "2. 访问量 TOP10 IP：" >> $OUTPUT_FILE
awk '{print $1}' $LOG_PATH | sort | uniq -c | sort -nr | head -10 | awk '{print "  第"NR"名："$2"，请求"$1"次"}' >> $OUTPUT_FILE

echo "" >> $OUTPUT_FILE
echo "3. HTTP状态码分布：" >> $OUTPUT_FILE
awk '{print $9}' $LOG_PATH | sort | uniq -c | sort -nr | awk '{print "  状态码"$2"："$1"次"}' >> $OUTPUT_FILE

echo "" >> $OUTPUT_FILE
echo "4. 请求量 TOP10 接口：" >> $OUTPUT_FILE
awk '{print $7}' $LOG_PATH | sort | uniq -c | sort -nr | head -10 | awk '{print "  第"NR"名："$2"，请求"$1"次"}' >> $OUTPUT_FILE

echo "===== 分析完成 =====" >> $OUTPUT_FILE
cat $OUTPUT_FILE
