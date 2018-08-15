#!/bin/bash
#version:01
#auther:Alicebat

MYSQLDBUSERNAME=root
# MYSQLDBPASSWORD是MySQL数据库的密码，可自定义
MYSQLDBPASSWORD=password
# MYSQBASEDIR是MySQL数据库的安装目录，--prefix=$MYSQBASEDIR，可自定义
MYSQBASEDIR=/usr/local/mysql
# MYSQL是mysql命令的绝对路径，可自定义
MYSQL=$MYSQBASEDIR/bin/mysql
# MYSQLDUMP是mysqldump命令的绝对路径，可自定义
MYSQLDUMP=$MYSQBASEDIR/bin/mysqldump
# BACKDIR是数据库备份的存放地址，可以自定义修改成远程地址
BACKDIR=/var/backup/db
# 获取当前时间，格式为：年-月-日，用于生成以这种时间格式的目录名称
DATEFORMATTYPE1=$(date +%Y-%m-%d)
# 获取当前时间，格式为：年月日时分秒，用于生成以这种时间格式的文件名称
DATEFORMATTYPE2=$(date +%Y%m%d%H%M%S)
# 如果存在MYSQBASEDIR目录，则将MYSQDATADIR设置为$MYSQBASEDIR/data，具体是什么路径，就把data改成什么路径，否则将MYSQBASEDIR设定为/var/lib/mysql，可自定义
[ -d $MYSQBASEDIR ] && MYSQDATADIR=$MYSQBASEDIR/data || MYSQDATADIR=/var/lib/mysql
# 如果mysql命令存在并可执行，则继续，否则将MYSQL设定为mysql，默认路径下的mysql
[ -x $MYSQL ] || MYSQL=mysql
# 如果mysqldump命令存在并可执行，则继续，否则将MYSQLDUMP设定为mysqldump，默认路径下的mysqldump
[ -x $MYSQLDUMP ] || MYSQLDUMP=mysqldump
# 如果不存在备份目录则创建这个目录
[ -d ${BACKDIR} ] || mkdir -p ${BACKDIR}
[ -d ${BACKDIR}/${DATEFORMATTYPE1} ] || mkdir ${BACKDIR}/${DATEFORMATTYPE1}
# 获取MySQL中有哪些数据库，根据mysqldatadir下的目录名字来确认，此处可以自定义，TODO
DBLIST=`ls -p $MYSQDATADIR | grep / |tr -d /`
# 从数据库列表中循环取出数据库名称，执行备份操作
for DBNAME in $DBLIST
    # mysqldump skip one table
    # -- Warning: Skipping the data of table mysql.event. Specify the --events option explicitly.
    # mysqldump --ignore-table=mysql.event
    # http://serverfault.com/questions/376904/mysqldump-skip-one-table
    # --routines，备份存储过程和函数
    # --events，跳过mysql.event表
    # --triggers，备份触发器
    # --single-transaction，针对InnoDB，在单次事务中通过转储所有数据库表创建一个一致性的快照，此选项会导致自动锁表，因此不需要--lock-all-tables
    # --flush-logs，在dump转储前刷新日志
    # --ignore-table，忽略某个表，--ignore-table=database.table
    # --master-data=2 ，如果启用MySQL复制功能，则可以添加这个选项
    # 将dump出的sql语句用gzip压缩到一个以时间命名的文件
    do ${MYSQLDUMP} --user=${MYSQLDBUSERNAME} --password=${MYSQLDBPASSWORD} --routines --events --triggers --single-transaction --flush-logs --ignore-table=mysql.event --databases ${DBNAME} | gzip > ${BACKDIR}/${DATEFORMATTYPE1}/${DBNAME}-backup-${DATEFORMATTYPE2}.sql.gz
    # 检查执行结果，如果错误代码为0则输出成功，否则输出失败
    [ $? -eq 0 ] && echo "${DBNAME} has been backuped successful" || echo "${DBNAME} has been backuped failed"
    # 等待5s，可自定义
    /bin/sleep 5
done
#该脚本可以反复执行，不会重复覆盖数据
#可增加，删除N天前的备份以节省磁盘空间
#充分利用mysqldump的自带锁表功能、刷新日志、复制等功能

