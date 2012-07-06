#!/bin/bash
# 这个SHELL用于监控Oracle数据库的会话数使用是否超出阈值

# 配置 应用ENV
. /home/oracle/monitorsh/env.sh

# 配置 日志文件位置
LOG_FILE=/home/oracle/monitorsh/log/session.log

# 配置 会话数, 使用比例
SW_USED_SESSION=1500
SW_USED_RATIO=70

# 配置 for循环 , 使用env.sh中设置的URL名称, 以便监控.
for i in "TNS_IDC1_APP2_RAC1_ORA" "TNS_IDC1_APP2_RAC2_ORA" "TNS_IDC4_APP1_ORA"
do
eval str="$"$i
ORA_SESSION_USAGE=`echo -e "set heading off;\n
set pagesize 0;\n
set verify off;\n
set echo off;\n
set feedback off;\n
set linesize 140;\n
set trimspool on;\n
set termout off;\n
column used format a10;\n
column max_sessions format a15;\n
column used_ratio format a10;\n
select t2.max_sessions,to_char(t1.used) used,to_char(trunc((t1.used/to_number(t2.max_sessions))*100)) used_ratio from (select count(*) used from v\\$session) t1 ,(select value max_sessions from v\\$parameter where name='sessions') t2;\n
quit;\n"|sqlplus -s $ORA_USER/$ORA_PWD@$str|col -x`

ORA_SESSION_DETAIL=`echo -e "set heading off;\n
set pagesize 0;\n
set verify off;\n
set echo off;\n
set feedback off;\n
set linesize 140;\n
set trimspool on;\n
set termout off;\n
column username format a18;\n
column machine format a42;\n
column module format a52;\n
column sessions format a10;\n
column status format a10;\n
select username,machine,module,status,to_char(count(*)) sessions from v\\$session group by username,machine,module,status order by username,machine,module,status;
quit;\n"|sqlplus -s $ORA_USER/$ORA_PWD@$str|col -x`

USED_SESSION=`echo -e $ORA_SESSION_USAGE|grep -v "^$"|awk '{print $2}'`
USED_RATIO=`echo -e $ORA_SESSION_USAGE|grep -v "^$"|awk '{print $3}'`

if [ $USED_SESSION -ge $SW_USED_SESSION ] || [ $USED_RATIO -ge $SW_USED_RATIO ]; then
echo -e "`date +%F%T`\n$i\n$str\nMAX_SESSION    USED      USED_RATIO\n$ORA_SESSION_USAGE\n\n\nDETAILS : \nUSERNAME          MACHINE                                   MODULE                                               STATUS  SESSIONS  \n$ORA_SESSION_DETAIL\n\nAuthor : Digoal\n\n" >> $LOG_FILE
echo -e "`date +%F%T`\n$i\n$str\nMAX_SESSION    USED      USED_RATIO\n$ORA_SESSION_USAGE\n\n\nDETAILS : \nUSERNAME          MACHINE                                   MODULE                                               STATUS  SESSIONS  \n$ORA_SESSION_DETAIL\n\nAuthor : Digoal\n\n"|mutt -s "WARNING : $i SESSION USED > BENCHMARK " $EMAIL &
fi
done

exit

# Author : Digoal zhou
# Email : digoal@126.com
# Blog : http://blog.163.com/digoal@126/