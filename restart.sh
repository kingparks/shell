# 重启动执行目录下的某个应用 例如：cd xxx;restart.sh test 
stop.sh $1;
start.sh $@;
