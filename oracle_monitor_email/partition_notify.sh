#!/bin/bash
# ���SHELL�����г�Oracle����������, ���ⰴʱ����еķ������Ǵ���

# ���� Ӧ��ENV
. /home/oracle/monitorsh/env.sh

# ���� ��־�ļ�λ��
LOG_FILE_PREFIX=/home/oracle/monitorsh/log/partition_notify.log

for i in "TNS_IDC1_APP2_RAC1_ORA" "TNS_IDC1_APP2_RAC2_ORA" "TNS_IDC4_APP1_ORA"
do
eval str="$"$i

echo -e "set linesize 140;\n
set pagesize 50000;\n
set long 20000000;\n
set longchunksize 20000;\n
set trimspool on;\n
set termout off;\n
column owner format a16;\n
column object_type format a32;\n
column object_name format a32;\n
column subobject_name format a32;\n
select owner,object_type,object_name,subobject_name from dba_objects where owner not in ('SYS','SYSTEM','MDSYS') and subobject_name is not null order by owner,object_type,object_name,subobject_name;\n
quit;\n"|sqlplus -s $ORA_USER/$ORA_PWD@$str|col -x > ${LOG_FILE_PREFIX}.$i
cat ${LOG_FILE_PREFIX}.$i | mutt -s "Patition Notice : $i $str (`date +%F%T`)" $EMAIL &

done

exit

# Author : Digoal zhou
# Email : digoal@126.com
# Blog : http://blog.163.com/digoal@126/