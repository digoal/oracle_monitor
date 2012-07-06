#!/bin/bash
# 这个SHELL用于监控job的运行时间 是否超时

# 配置 应用ENV
. /home/oracle/monitorsh/env.sh

# 配置 日志文件位置
LOG_FILE=/home/oracle/monitorsh/log/jobs_mon.log

# 配置 JOB运行超时阈值 分钟
RUN_TIMEOUT=75

# 监控函数
jobs_timeout()
{
V_USER=$1
V_PWD=$2
V_TNS=$3
V_DB_ALIAS=$4

JOBS_TIMEOUT=`echo -e "set heading off;\n
set pagesize 0;\n
set verify off;\n
set echo off;\n
set feedback off;\n
set linesize 140;\n
set trimspool on;\n
set termout off;\n
select * from dba_jobs where (sysdate-this_date)>${RUN_TIMEOUT}/1440;\n
quit;\n"|sqlplus -s $V_USER/$V_PWD@$V_TNS|col -x`

JOBS_RUN_TIMEOUT=`echo -e "set heading off;\n
set pagesize 0;\n
set verify off;\n
set echo off;\n
set feedback off;\n
set linesize 140;\n
set trimspool on;\n
set termout off;\n
select * from dba_jobs_running where (sysdate-this_date)>${RUN_TIMEOUT}/1440;\n
quit;\n"|sqlplus -s $V_USER/$V_PWD@$V_TNS|col -x`

echo -e $JOBS_TIMEOUT|grep -v "^$"
echo -e $JOBS_RUN_TIMEOUT|grep -v "^$"

LINE1=`echo -e $JOBS_TIMEOUT|grep -v "^$"|wc -l`
LINE2=`echo -e $JOBS_RUN_TIMEOUT|grep -v "^$"|wc -l`

if [ $LINE1 -ge 1 ] || [ $LINE2 -ge 1 ]; then
echo -e "`date +%F%T`\n$V_DB_ALIAS\n$V_TNS\n$JOBS_TIMEOUT\n\n\n\n$JOBS_RUN_TIMEOUT\n\nAuthor : Digoal\n\n" >> $LOG_FILE
echo -e "`date +%F%T`\n$V_DB_ALIAS\n$V_TNS\n$JOBS_TIMEOUT\n\n\n\n$JOBS_RUN_TIMEOUT\n\nAuthor : Digoal\n\n"|mutt -s "WARNING : $V_DB_ALIAS JOBS RUN > BENCHMARK: ${RUN_TIMEOUT} minutes. " $EMAIL
fi
}

# 配置 for循环 , 使用env.sh中设置的URL名称, 以便监控.
for i in "TNS_IDC1_APP2_RAC1_ORA" "TNS_IDC1_APP2_RAC2_ORA" "TNS_IDC4_APP1_ORA"
do
eval str="$"$i

jobs_timeout $ORA_USER $ORA_PWD $str $i &

done

exit

# Author : Digoal zhou
# Email : digoal@126.com
# Blog : http://blog.163.com/digoal@126/