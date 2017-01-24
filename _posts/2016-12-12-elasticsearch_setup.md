---
layout: post
title:  "ElasticSearch安装"
date:   2016-12-12 10:46:06 +0800
categories: es
---
# 概述

es有多猛就不嘚嘚了，本文档描述了使用es过程中会遇到的些问题

# ES安装

## 添加用户
所有程序要跑在自己的用户下，不可用root运行任何应用程序。
{% highlight shell %}
su - root
useradd -m -s /bin/bash qzt_es
{% endhighlight %}

## jdk环境
{% highlight shell %}
jdk-8u73-linux-x64.tar.gz
export JAVA_HOME=/home/qzt_es/jdk1.8.0_73
export CLASSPATH=$JAVA_HOME/lib:$JAVA_HOME/jre/lib:.
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH
{% endhighlight %}

## es配置文件
{% highlight shell %}
cluster.name: qzt360-es
node.name: node-01
network.host: 192.168.36.28
discovery.zen.ping.unicast.hosts: ["192.168.36.28", "192.168.36.31"]
node.master: true
node.data: false/true
{% endhighlight %}

## 启动脚本
{% highlight shell %}
#!/bin/bash
for i in `jps | grep Elasticsearch | awk '{print$1}'`
do
  echo "kill "$i
  kill $i
done
sleep 7
export ES_HEAP_SIZE=4g
/home/qzt_es/elasticsearch-2.3.3/bin/elasticsearch -d
echo "ES restart done!"
{% endhighlight %}
# Kibana安装
{% highlight shell %}
# config配置
elasticsearch.url: "http://192.168.36.28:9200"
{% endhighlight %}