# 停止当前目录下的某个应用 例如：./stop.sh test
app=$1
echo "stop $app"
# 当前目录
script_dir=$(cd "$(dirname $0)";pwd)/
pids=`ps -ef | grep $app | grep -v 'cd'| grep -v 'grep' | awk '{print $2}' | while read line; do pwdx $line; done`
pids=`echo "$pids" | awk '{print $0"/"}'`
echo "$pids" | grep "$script_dir" | cut -d':' -f1 | while read line; do kill $line; done;