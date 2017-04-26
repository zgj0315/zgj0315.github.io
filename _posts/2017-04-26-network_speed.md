---
layout: post
title:  "徒手查看网卡速度"
date:   2017-04-26 10:39:06 +0800
categories: linux
---

# 缘起
Linux上调试程序性能时，需要看网卡的实时速度，如果瓶颈在网卡，程序再优化也没什么鸟用

# 解决办法
网上资料会让你装各种工具实现这个目标，终于被我找到了一个脚本实现的方式

```
#!/bin/bash
while [ "1" ]
do
eth=$1
RXpre=$(cat /proc/net/dev | grep $eth | tr : " " | awk '{print $2}')
TXpre=$(cat /proc/net/dev | grep $eth | tr : " " | awk '{print $10}')
sleep 1
RXnext=$(cat /proc/net/dev | grep $eth | tr : " " | awk '{print $2}')
TXnext=$(cat /proc/net/dev | grep $eth | tr : " " | awk '{print $10}')
clear
echo -e "\t RX `date +%k:%M:%S` TX"
RX=$(($RXnext-$RXpre))
TX=$(($TXnext-$TXpre))

if [[ $RX -lt 1024 ]];then
RX="${RX}B/s"
elif [[ $RX -gt 1048576 ]];then
RX=$(echo $RX | awk '{print $1/1048576 "MB/s"}')
else
RX=$(echo $RX | awk '{print $1/1024 "KB/s"}')
fi

if [[ $TX -lt 1024 ]];then
TX="${TX}B/s"
elif [[ $TX -gt 1048576 ]];then
TX=$(echo $TX | awk '{print $1/1048576 "MB/s"}')
else
TX=$(echo $TX | awk '{print $1/1024 "KB/s"}')
fi

echo -e "$eth \t $RX $TX "
done
```

把文件保存为traff.sh，手工看看/proc/net/dev文件中你需要看哪个网卡，执行./traff.sh em1就行了，Ctrl+C退出