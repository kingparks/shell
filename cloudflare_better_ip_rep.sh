#!/bin/bash
# 检测并自动替换 cloudflare 下域名的 hosts ip
# 例如： sudo cloudflare_better_ip_rep.sh eiyou.ml

domainName=$1
if [ -z "$domainName" ]; then
  read -p "请输入一个要加速的域名:" domainName
fi
if [ -z "$domainName" ]; then
  echo '要跟上加速的域名'
  exit
fi
oldIP=$(cat /etc/hosts | grep $domainName | head -1 | cut -d' ' -f1)
if [ -z "$oldIP" ]; then
  echo '未在hosts文件中找的' domainName
  exit
fi

curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/badafans/better-cloudflare-ip/master/shell/cf.sh >cf.sh
sed -i '' 's/read -p "请选择菜单(默认0): " menu/menu=1/' cf.sh
sed -i '' 's/read -p "请设置期望的带宽大小(默认最小1,单位 Mbps):" bandwidth/bandwidth=1/' cf.sh
sed -i '' 's/read -p "请设置RTT测试进程数(默认10,最大50):" tasknum/tasknum=10/' cf.sh
sed -i '' 's/ips-v4.txt/tmp_ips-v4.txt/' cf.sh
sed -i '' 's/ips-v6.txt/tmp_ips-v6.txt/' cf.sh
sed -i '' 's/colo.txt/tmp_colo.txt/' cf.sh
sed -i '' 's/url.txt/tmp_url.txt/' cf.sh
echo '执行中请等待...'
bash cf.sh >tmp_cf_result.txt
rm cf.sh tmp_ips-v4.txt tmp_ips-v6.txt tmp_url.txt tmp_colo.txt
newIP=$(cat tmp_cf_result.txt | grep '优选IP' | cut -d' ' -f2)
rm tmp_cf_result.txt
if [ -z "$newIP" ]; then
  echo '未找到优选IP'
  exit
fi

echo 'hosts 文件的 ip 由' $oldIP '变为' $newIP
sudo sed -i "" "s/$oldIP/$newIP/g" /etc/hosts

