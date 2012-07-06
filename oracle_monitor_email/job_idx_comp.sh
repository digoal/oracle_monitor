#!/bin/bash
# 这个SHELL用于监控job的状态, index的状态, 函数和过程等编译状态 是否正常

# 配置 应用ENV
. /home/oracle/monitorsh/env.sh

# 配置 日志文件位置
LOG_FILE=/home/oracle/monitorsh/log/job_idx_comp.log

# 监控函数
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
set linesize 140;\n
set trimspool on;\n
set termout off;\n
select to_char(job) jobid,schema_user,broken,to_char(failures) failures,what from sys.dba_jobs where failures>0 or broken='Y';\n
quit;\n"|sqlplus -s $V_USER/$V_PWD@$V_TNS|col -x`

INDEX_FAILURE=`echo -e "set heading off;\n
set pagesize 0;\n
set verify off;\n
set echo off;\n
set feedback off;\n
set linesize 140;\n
set trimspool on;\n
set termout off;\n
select owner,index_name,table_name,status from sys.dba_indexes where status not in ('VALID','N/A') and index_name<>'IDX_DOWNLOAD_ERR_P1';\n
quit;\n"|sqlplus -s $V_USER/$V_PWD@$V_TNS|col -x`

COMP_FAILURE=`echo -e "set heading off;\n
set pagesize 0;\n
set verify off;\n
set echo off;\n
set feedback off;\n
set linesize 140;\n
set trimspool on;\n
set termout off;\n
select owner,name,type from dba_errors group by owner,name,type;\n
quit;\n"|sqlplus -s $V_USER/$V_PWD@$V_TNS|col -x`


LINE_JOB=`echo -e $JOBS_FAILURE|grep -v "^$"|wc -l`
LINE_INDEX=`echo -e $INDEX_FAILURE|grep -v "^$"|wc -l`
LINE_COMP=`echo -e $COMP_FAILURE|grep -v "^$"|wc -l`

if [ $LINE_JOB -ge 1 ] || [ $LINE_INDEX -ge 1 ] || [ $LINE_COMP -ge 1 ]; then
echo -e "`date +%F%T`\n$V_ALIAS\n$V_TNS\nJOBS_FAILURE : \njobid    schema_user    broken    failures    what    \n$JOBS_FAILURE\n\nINDEX_FAILURE : \nowner        index_name        table_name        status    \n$INDEX_FAILURE\n\nCOMP_FAILURE : \nowner        name        type        \n$COMP_FAILURE\n\nAuthor : Digoal\n\n" >> $LOG_FILE
echo -e "`date +%F%T`\n$V_ALIAS\n$V_TNS\nJOBS_FAILURE : \njobid    schema_user    broken    failures    what    \n$JOBS_FAILURE\n\nINDEX_FAILURE : \nowner        index_name        table_name        status    \n$INDEX_FAILURE\n\nCOMP_FAILURE : \nowner        name        type        \n$COMP_FAILURE\n\nAuthor : Digoal\n\n"|mutt -s "ERROR : $V_ALIAS JOB/INDEX/COMP ABNORMAL" $EMAIL
fi
}

# 配置 for循环 , 使用env.sh中设置的URL名称, 以便监控.
for i in "TNS_IDC1_APP2_RAC1_ORA" "TNS_IDC1_APP2_RAC2_ORA" "TNS_IDC4_APP1_ORA"
do
eval str="$"$i
f_mon $ORA_USER $ORA_PWD $str $i &
done

exit

# Author : Digoal zhou
# Email : digoal@126.com
# Blog : http://blog.163.com/digoal@126/