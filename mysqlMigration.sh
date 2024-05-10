# mysql 从一个数据库复制到另一个数据库
# 参数分别为源数据库及目标数据库的ip,port,username,password,dbname
p10=${10}
if [ -z "$p10" ]; then
  echo "参数分别为源数据库及目标数据库的ip,port,username,password,dbname"
  echo "请补全参数重新执行，一共10个参数"
  exit
fi
mysqldump --skip-triggers -h$1 -P$2 -u$3 -p$4 $5 > mysqlMigration_$5.sql;
echo "导出完成："mysqlMigration_$5.sql;
mysql -h$6 -P$7 -u$8 -p$9 ${10} < mysqlMigration_$5.sql;
echo "导入完成："mysqlMigration_$5.sql;