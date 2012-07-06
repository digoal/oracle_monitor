#!/bin/bash
# 这个SHELL用于监控asm的使用

# 配置 应用ENV
. /home/oracle/monitorsh/env.sh

# 配置 日志文件位置
LOG_FILE=/home/oracle/monitorsh/log/asm_usage.log

# 配置 阈值, 可用空间MB, 剩余百分比.
USABLE_FILE_MB=50000
ASMDG_FREE=50

# 配置 for循环 , 使用env.sh中设置的URL名称, 以便监控.
for i in "PORT_IDC1_APP2_RAC1_ORA" "PORT_IDC1_APP2_RAC2_ORA"
do
eval str="$"$i
ASM_USAGE=`echo -e "set heading off;\n
set pagesize 0;\n
set verify off;\n
set echo off;\n
set feedback off;\n
set linesize 140;\n
set trimspool on;\n
set termout off;\n
set numwidth 10;\n
column name format a12;\n
column state format a10;\n
column type format a12;\n
column free_ratio format a10;\n
select name,state,type,total_mb,usable_file_mb free_mb,trunc(((usable_file_mb+0.1)/(total_mb+10)),4)*100 || ' %' free_ratio from v\\$asm_diskgroup where usable_file_mb < $USABLE_FILE_MB or trunc(((usable_file_mb + 0.1) / (total_mb + 10)), 4) * 100 < $ASMDG_FREE order by name;\n
quit;\n"|sqlplus -s $ORA_USER/$ORA_PWD@$str|col -x`

LINE=`echo -e $ASM_USAGE|grep -v "^$"|wc -l`
if [ $LINE -ge 1 ]; then
echo -e "`date +%F%T`\n$i\n$str\nASMDG_NAME   STATE      TYPE           TOTAL_MB  USABLE_MB FREE_RATIO\n$ASM_USAGE\n\nAuthor : Digoal\n\n" >> $LOG_FILE
echo -e "`date +%F%T`\n$i\n$str\nASMDG_NAME   STATE      TYPE           TOTAL_MB  USABLE_MB FREE_RATIO\n$ASM_USAGE\n\nAuthor : Digoal\n\n"|mutt -s "WARNING : $i ASMDG_FREE < ${ASMDG_FREE}%" $EMAIL &
fi
done

exit

# Author : Digoal zhou
# Email : digoal@126.com
# Blog : http://blog.163.com/digoal@126/