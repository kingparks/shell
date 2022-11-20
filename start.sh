# 启动执行目录下的某个应用 例如：cd xxx;start.sh test 
app=$1
echo "start $app"
# 脚本目录
#script_dir=$(cd "$(dirname $0)";pwd)/
# 执行目录
script_dir=$(pwd)/
nohup ${script_dir}${app} > ${script_dir}${app}.out 2>&1 &
