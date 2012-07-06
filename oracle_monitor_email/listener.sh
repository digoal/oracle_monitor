#!/bin/bash
# 这个SHELL用于监控数据库的监听端口是否正常

# 配置 应用ENV
. /home/oracle/monitorsh/env.sh

# 配置 日志文件位置
LOG_FILE=/home/oracle/monitorsh/log/listener.log

for i in "PORT_IDC1_APP1_PG" "PORT_IDC1_APP2_RAC1_ORA" "PORT_IDC1_APP2_RAC2_ORA" "PORT_IDC2_APP1_PG" "PORT_IDC2_APP2_PG" "PORT_IDC3_APP1_MONGODB" "PORT_IDC3_APP2_MYSQL" "PORT_IDC4_APP1_ORA" "PORT_IDC4_APP2_REDIS"
do
eval str="$"$i
echo -e "q"|telnet -e "q" $str || echo -e "`date`\n\n $i $str listener abormal.\n\nAuthor : (Digoal) "|mutt -s "$i DB listener error" $EMAIL  | echo -e "`date +%F%T` $str cannot reach." >> $LOG_FILE &
done

exit

# Author : Digoal zhou
# Email : digoal@126.com
# Blog : http://blog.163.com/digoal@126/