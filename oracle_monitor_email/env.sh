# 本文件用于配置要监控的监听端口, 连接Oracle数据库的URL, 用户密码, 发生异常时发送信息到哪个邮箱.
# 环境变量
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0.2/db_1
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib64:/usr/lib64:/usr/local/lib64:$ORACLE_HOME/lib32:/lib:/usr/lib:/usr/local/lib
export PATH=$ORACLE_HOME/bin:$PATH:.
export NLS_DATE_FORMAT='yyyy-mm-dd hh24:mi:ss'
export NLS_LANG=AMERICAN_AMERICA.UTF8
export LANG=en_US.utf8

# listener env
# IDC-1
PORT_IDC1_APP1_PG="192.168.1.100 5432"
PORT_IDC1_APP2_RAC1_ORA="192.168.1.101 1521"
PORT_IDC1_APP2_RAC2_ORA="192.168.1.102 1521"
# IDC-2
PORT_IDC2_APP1_PG="192.168.11.100 5432"
PORT_IDC2_APP2_PG="192.168.11.101 5432"
# IDC-3
PORT_IDC3_APP1_MONGODB="192.168.21.100 5281"
PORT_IDC3_APP2_MYSQL="192.168.21.100 3306"
# IDC-4
PORT_IDC4_APP1_ORA="192.168.31.35 1521"
PORT_IDC4_APP2_REDIS="192.168.31.36 1522"


# TNS env
# IDC-1
# 监控所有的Oracle RAC节点
TNS_IDC1_APP2_RAC1_ORA="//192.168.1.101:1521/digoal"
TNS_IDC1_APP2_RAC2_ORA="//192.168.1.102:1521/digoal"
# IDC-4
TNS_IDC4_APP1_ORA="//192.168.31.35:1521/digoal"


# 告警邮件, 多个用空格隔开
EMAIL="digoal@126.com"

# PWD, 所有被监控的数据库的用户密码必须一致, 赋予connect, select_catalog_role权限.
ORA_USER="db_monitor"
ORA_PWD=\"DB_monitoR_1983\"


# Author : Digoal zhou
# Email : digoal@126.com
# Blog : http://blog.163.com/digoal@126/
