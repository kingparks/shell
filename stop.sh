# 停止执行目录下的某个应用 例如：cd xxx;stop.sh test
app=$1
echo "stop $app"
# 脚本目录
#script_dir=$(cd "$(dirname $0)";pwd)/
# 执行目录
script_dir=$(pwd)/
pids=`ps -ef | grep $app | grep -v 'cd'| grep -v 'grep' | awk '{print $2}' | while read line; do pwdx $line; done`
echo "heshu: $pids"
pids=`echo "$pids" | awk '{print $0"/"}'`
echo "$pids" | grep "$script_dir" | cut -d':' -f1 | while read line; do kill $line; done;
