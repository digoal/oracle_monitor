#!/bin/bash
# 这个SHELL用于监控数据库job的运行状态, 参数为env.sh中配置的TNS别名

# 配置 应用ENV
. /home/oracle/monitorsh/env.sh

# 配置 日志文件以及临时日志文件位置
LOG_FILE=/home/oracle/monitorsh/log/job_nagios_$1.log
TEMP_FILE=/tmp/job_nagios_$1.tmp

RETVAL=0

f_mon()
{
V_USER=$1
V_PWD=$2
V_TNS=$3
V_ALIAS=$4

JOBS_FAILURE=`echo -e "set heading off;\n
set pagesize 0;\n
set verify off;\n
set echo off;\n
set feedback off;\n
set linesize 120;\n
set trimspool on;\n
set termout off;\n
column schema_user format a32;\n
column broken format a6;\n
column what format a30;\n
select to_char(job) jobid,schema_user,broken,to_char(failures) failures,what from sys.dba_jobs where failures>0 or broken='Y';\n
quit;\n"|sqlplus -s $V_USER/$V_PWD@$V_TNS|col -x`

LINE_JOB=`echo -e $JOBS_FAILURE|grep -v "^$"|wc -l`

if [ $LINE_JOB -ge 1 ]; then
  RETVAL=1
  echo -e "`date +%F\ %T`\n$V_ALIAS\n$V_TNS\nJOBS_FAILURE : \njobid    schema_user    broken    failures    what    \n$JOBS_FAILURE\n\n" >> $LOG_FILE
  echo -e "`date +%F\ %T`\n$V_ALIAS\n$V_TNS\nJOBS_FAILURE : \njobid    schema_user    broken    failures    what    \n$JOBS_FAILURE\n\n" > $TEMP_FILE
  grep -E "N\ +16|Y\ +16" $TEMP_FILE
  if [ $? -eq 0 ]; then
  RETVAL=2
  fi
fi
}

eval str="$"$1
f_mon $ORA_USER $ORA_PWD $str $1

if [ $LINE_JOB -ge 1 ]; then
cat $TEMP_FILE
fi

exit $RETVAL

# Author : Digoal zhou
# Email : digoal@126.com
# Blog : http://blog.163.com/digoal@126/