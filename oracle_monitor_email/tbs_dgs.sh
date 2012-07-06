#!/bin/bash
# 这个SHELL用于监控job的运行时间 是否超时

# 配置 应用ENV
. /home/oracle/monitorsh/env.sh

# 配置 日志文件位置
LOG_FILE=/home/oracle/monitorsh/log/tbs_dgs.log

# 分时段监控用到的时间格式
DATE=`date +%H`

# 配置 for循环 , 使用env.sh中设置的URL名称, 以便监控.
for i in "TNS_IDC1_APP2_RAC1_ORA" "TNS_IDC1_APP2_RAC2_ORA" "TNS_IDC4_APP1_ORA"
do
eval str="$"$i
# 09到22点
if [ $DATE == 09 ] || [ $DATE == 10 ] || [ $DATE == 11 ] || [ $DATE == 12 ] || [ $DATE == 13 ] || [ $DATE == 14 ] || [ $DATE == 15 ] || [ $DATE == 16 ] || [ $DATE == 17 ] || [ $DATE == 18 ] || [ $DATE == 19 ] || [ $DATE == 20 ] || [ $DATE == 21 ] || [ $DATE == 22 ] || [ $DATE == 23 ]; then
TBS_USAGE=`echo -e "set heading off;\n
set pagesize 0;\n
set verify off;\n
set echo off;\n
set feedback off;\n
set linesize 140;\n
set trimspool on;\n
set termout off;\n
column free_mbs format a32;\n
column total_mbs format a10;\n
column tbs_name format a32;\n
select t1.tbs tbs_name,to_char(t2.mbs)||'MB' total_mbs,to_char(t1.mbs)||case when t2.mbs <= 100 then 'MB,Require 9MB free' when t2.mbs > 100 and t2.mbs<=2048 then 'MB,Require 512MB free' when t2.mbs>2048 and t2.mbs<=12000 then 'MB,Require 1280MB free' when t2.mbs>12000 then 'MB,Require 5120MB free' else null end free_mbs,'\\\\\\\\n' ok from (select trunc(sum(bytes)/1024/1024) mbs,tablespace_name tbs from sys.dba_free_space group by tablespace_name) t1,(select trunc(sum(bytes)/1024/1024) mbs,tablespace_name tbs from sys.dba_data_files group by tablespace_name) t2 where t1.tbs=t2.tbs and ((t2.mbs <= 100 and t1.mbs < 9) or (t2.mbs>100 and t2.mbs<=2048 and t1.mbs<512) or (t2.mbs>2048 and t2.mbs<=12000 and t1.mbs<1280) or (t2.mbs>12000 and t1.mbs<5120));\n
quit;\n"|sqlplus -s $ORA_USER/$ORA_PWD@$str|col -x`
fi

# 00到08点
if [ $DATE == 00 ] || [ $DATE == 01 ] || [ $DATE == 02 ] || [ $DATE == 03 ] || [ $DATE == 04 ] || [ $DATE == 05 ] || [ $DATE == 06 ] || [ $DATE == 07 ] || [ $DATE == 08 ]; then
TBS_USAGE=`echo -e "set heading off;\n
set pagesize 0;\n
set verify off;\n
set echo off;\n
set feedback off;\n
set linesize 140;\n
set trimspool on;\n
set termout off;\n
column free_mbs format a32;\n
column total_mbs format a10;\n
column tbs_name format a32;\n
select t1.tbs tbs_name,to_char(t2.mbs)||'MB' total_mbs,to_char(t1.mbs)||case when t2.mbs <= 100 then 'MB,Require 9MB free' when t2.mbs > 100 and t2.mbs<=2048 then 'MB,Require 100MB free' when t2.mbs>2048 and t2.mbs<=12000 then 'MB,Require 512MB free' when t2.mbs>12000 then 'MB,Require 4096MB free' else null end free_mbs,'\\\\\\\\n' ok from (select trunc(sum(bytes)/1024/1024) mbs,tablespace_name tbs from sys.dba_free_space group by tablespace_name) t1,(select trunc(sum(bytes)/1024/1024) mbs,tablespace_name tbs from sys.dba_data_files group by tablespace_name) t2 where t1.tbs=t2.tbs and ((t2.mbs <= 100 and t1.mbs < 9) or (t2.mbs>100 and t2.mbs<=2048 and t1.mbs<100) or (t2.mbs>2048 and t2.mbs<=12000 and t1.mbs<512) or (t2.mbs>12000 and t1.mbs<4096));\n
quit;\n"|sqlplus -s $ORA_USER/$ORA_PWD@$str|col -x`
fi

LINE=`echo -e $TBS_USAGE|grep -v "^$"|wc -l`
if [ $LINE -ge 1 ]; then
echo -e "`date +%F%T`\n$i\n$str\nTBS_NAME                         TOTAL_MB   FREE                         \n$TBS_USAGE\n\n\nAuthor : Digoal\n\n" >> $LOG_FILE
echo -e "`date +%F%T`\n$i\n$str\nTBS_NAME                         TOTAL_MB   FREE                         \n$TBS_USAGE\n\n\nAuthor : Digoal\n\n"|mutt -s "WARNING : $i (Please add datafile or extend datafiles)" $EMAIL &
fi
done

exit

# Author : Digoal zhou
# Email : digoal@126.com
# Blog : http://blog.163.com/digoal@126/