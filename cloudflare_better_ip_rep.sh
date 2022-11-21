#!/bin/bash
# 检测并自动替换 cloudflare 下域名的 hosts ip
# 例如： sudo cloudflare_better_ip_rep.sh eiyou.ml
function bettercloudflareip() {
  if [ -z "$bandwidth" ]; then
    bandwidth=1
  fi
  if [ $bandwidth -eq 0 ]; then
    bandwidth=1
  fi
  if [ -z "$tasknum" ]; then
    tasknum=10
  fi
  if [ $tasknum -eq 0 ]; then
    echo "进程数不能为0,自动设置为默认值"
    tasknum=10
  fi
  if [ $tasknum -gt 50 ]; then
    echo "超过最大进程限制,自动设置为最大值"
    tasknum=50
  fi
  speed=$(($bandwidth * 128 * 1024))
  starttime=$(date +%s)
  cloudflaretest
  realbandwidth=$(($max / 128))
  endtime=$(date +%s)
  echo "从服务器获取详细信息"
  curl --$ips --resolve service.baipiaocf.ml:443:$anycast --retry 1 -s -X POST https://service.baipiaocf.ml -o temp.txt --connect-timeout 2 --max-time 3
  clear
  if [ ! -f "temp.txt" ]; then
    publicip=获取超时
    colo=获取超时
  else
    publicip=$(grep publicip= temp.txt | cut -f 2- -d'=')
    colo=$(grep colo= temp.txt | cut -f 2- -d'=')
    rm -rf temp.txt
  #	echo $anycast>$ips.txt
  fi
  echo "优选IP $anycast"
  echo "公网IP $publicip"
  echo "自治域 AS$asn"
  echo "运营商 $isp"
  echo "经纬度 $longitude,$latitude"
  echo "位置信息 $city,$region,$country"
  echo "设置带宽 $bandwidth Mbps"
  echo "实测带宽 $realbandwidth Mbps"
  echo "峰值速度 $max kB/s"
  echo "往返延迟 $avgms 毫秒"
  echo "数据中心 $colo"
  echo "总计用时 $(($endtime - $starttime)) 秒"
}
function cloudflaretest() {
  while true; do
    while true; do
      rm -rf rtt rtt.txt data.txt meta.txt log.txt anycast.txt temp.txt speed.txt
      mkdir rtt
      while true; do
        if [ ! -f "$ips.txt" ]; then
          echo "DNS解析获取CF $ips 节点"
          echo "如果域名被污染,请手动创建 $ips.txt 做解析"
          while true; do
            if [ ! -f "meta.txt" ]; then
              curl --$ips --retry 1 -s https://service.baipiaocf.ml/meta -o meta.txt --connect-timeout 2 --max-time 3
            else
              asn=$(grep asn= meta.txt | cut -f 2- -d'=')
              isp=$(grep isp= meta.txt | cut -f 2- -d'=')
              country=$(grep country= meta.txt | cut -f 2- -d'=')
              region=$(grep region= meta.txt | cut -f 2- -d'=')
              city=$(grep city= meta.txt | cut -f 2- -d'=')
              longitude=$(grep longitude= meta.txt | cut -f 2- -d'=')
              latitude=$(grep latitude= meta.txt | cut -f 2- -d'=')
              curl --$ips --retry 1 https://service.baipiaocf.ml -o data.txt -# --connect-timeout 2 --max-time 3
              break
            fi
          done
        else
          echo "指向解析获取CF $ips 节点"
          echo "如果长时间无法获取CF $ips 节点,重新运行程序并选择清空缓存"
          resolveip=$(cat $ips.txt)
          while true; do
            if [ ! -f "meta.txt" ]; then
              curl --$ips --resolve service.baipiaocf.ml:443:$resolveip --retry 1 -s https://service.baipiaocf.ml/meta -o meta.txt --connect-timeout 2 --max-time 3
            else
              asn=$(grep asn= meta.txt | cut -f 2- -d'=')
              isp=$(grep isp= meta.txt | cut -f 2- -d'=')
              country=$(grep country= meta.txt | cut -f 2- -d'=')
              region=$(grep region= meta.txt | cut -f 2- -d'=')
              city=$(grep city= meta.txt | cut -f 2- -d'=')
              longitude=$(grep longitude= meta.txt | cut -f 2- -d'=')
              latitude=$(grep latitude= meta.txt | cut -f 2- -d'=')
              curl --$ips --resolve service.baipiaocf.ml:443:$resolveip --retry 1 https://service.baipiaocf.ml -o data.txt -# --connect-timeout 2 --max-time 3
              break
            fi
          done
        fi
        if [ -f "data.txt" ]; then
          break
        fi
      done
      domain=$(grep domain= data.txt | cut -f 2- -d'=')
      file=$(grep file= data.txt | cut -f 2- -d'=')
      url=$(grep url= data.txt | cut -f 2- -d'=')
      app=$(grep app= data.txt | cut -f 2- -d'=')

      for i in $(cat data.txt | sed '1,4d'); do
        echo $i >>anycast.txt
      done
      rm -rf meta.txt data.txt
      ipnum=$(cat anycast.txt | wc -l)
      if [ $tasknum == 0 ]; then
        tasknum=1
      fi
      if [ $ipnum -lt $tasknum ]; then
        tasknum=$ipnum
      fi
      n=1
      for i in $(cat anycast.txt); do
        echo $i >>rtt/$n.txt
        if [ $n == $tasknum ]; then
          n=1
        else
          n=$(($n + 1))
        fi
      done
      rm -rf anycast.txt
      n=1
      while true; do
        rtt $n &
        if [ $n == $tasknum ]; then
          break
        else
          n=$(($n + 1))
        fi
      done
      while true; do
        n=$(ls rtt | grep txt | wc -l)
        if [ $n -ne 0 ]; then
          echo "$(date +'%H:%M:%S') 等待RTT测试结束,剩余进程数 $n"
        else
          echo "$(date +'%H:%M:%S') RTT测试完成"
          break
        fi
        sleep 1
      done
      n=$(ls rtt | grep log | wc -l)
      if [ $n == 0 ]; then
        echo "当前所有IP都存在RTT丢包"
      else
        cat rtt/*.log >rtt.txt
        status=0
        echo "待测速的IP地址"
        cat rtt.txt | sort | awk '{print $2" 往返延迟 "$1" 毫秒"}'
        for i in $(cat rtt.txt | sort | awk '{print $1"_"$2}'); do
          avgms=$(echo $i | awk -F_ '{print $1}')
          ip=$(echo $i | awk -F_ '{print $2}')
          echo "正在测试 $ip"
          max=$(speedtest $ip)
          if [ $max -ge $speed ]; then
            status=1
            anycast=$ip
            max=$(($max / 1024))
            echo "$ip 峰值速度 $max kB/s"
            #            echo "IP地址,往返延迟" >$ips.csv
            #            cat rtt.txt | sort | awk '{print $2","$1" ms"}' >>$ips.csv
            rm -rf rtt rtt.txt
            break
          else
            max=$(($max / 1024))
            echo "$ip 峰值速度 $max kB/s"
          fi
        done
        if [ $status == 1 ]; then
          break
        fi
      fi
    done
    break
  done
}
function rtt() {
  avgms=0
  n=1
  for ip in $(cat rtt/$1.txt); do
    while true; do
      if [ $n -le 3 ]; then
        rsp=$(curl --resolve www.cloudflare.com:443:$ip https://www.cloudflare.com/cdn-cgi/trace -o /dev/null -s --connect-timeout 1 --max-time 3 -w %{time_connect}_%{http_code})
        if [ $(echo $rsp | awk -F_ '{print $2}') != 200 ]; then
          avgms=0
          n=1
          break
        else
          avgms=$(($(echo $rsp | awk -F_ '{printf ("%d\n",$1*1000000)}') + $avgms))
          n=$(($n + 1))
        fi
      else
        avgms=$(($avgms / 3000))
        if [ $avgms -lt 10 ]; then
          echo 00$avgms $ip >>rtt/$1.log
        elif [ $avgms -ge 10 ] && [ $avgms -lt 100 ]; then
          echo 0$avgms $ip >>rtt/$1.log
        else
          echo $avgms $ip >>rtt/$1.log
        fi
        avgms=0
        n=1
        break
      fi
    done
  done
  rm -rf rtt/$1.txt
}

function speedtest() {
  rm -rf log.txt speed.txt
  curl --resolve $domain:443:$1 https://$domain/$file -o /dev/null --connect-timeout 1 --max-time 10 >log.txt 2>&1
  cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep -v 'k\|M' >>speed.txt
  for i in $(cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep k | sed 's/k//g'); do
    k=$i
    k=$(($k * 1024))
    echo $k >>speed.txt
  done
  for i in $(cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep M | sed 's/M//g'); do
    i=$(echo | awk '{print '$i'*10 }')
    M=$i
    M=$(($M * 1024 * 1024 / 10))
    echo $M >>speed.txt
  done
  max=0
  for i in $(cat speed.txt); do
    if [ $i -ge $max ]; then
      max=$i
    fi
  done
  rm -rf log.txt speed.txt
  echo $max
}

ips=ipv4
domainName=$1

if [ -z "$domainName" ]; then
  read -p "请输入一个要加速的域名:" domainName
fi
if [ -z "$domainName" ]; then
  echo '要跟上加速的域名'
  exit
fi
oldIP=$(cat /etc/hosts | grep $domainName | head -1| cut -d' ' -f1)
if [ -z "$oldIP" ]; then
  echo '未在hosts文件中找的' domainName
  exit
fi

bettercloudflareip
echo 'hosts 文件的 ip 由' $oldIP '变为' $anycast
sed -i "" "s/$oldIP/$anycast/g" /etc/hosts


