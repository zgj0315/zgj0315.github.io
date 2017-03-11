---
layout: post
title:  "ElasticSearch-5.2.2部署"
date:   2017-03-09 15:48:00 +0800
categories: es
---

# 1 概述
所有的研究都是要用于生产环境的，大神们都说，所有的x.x.0的版本尽量不要用，因为bug相对较多，ES在2017年02月28日发布了5.2.2版本，本文档就以这版本为例，部署到服务器上进行部分性能测试和调优。

# 2 环境
7台服务器，本来是用于hadoop集群的，借用进行es测试，服务器的交换分区设置的都为0，硬盘是raid0，内存是16G，cpu是2颗*12核。

编号|名称|IP|角色
:---:|:---:|:---:|:---:
1|datanode01|192.168.10.12|data
2|datanode02|192.168.10.13|data
3|datanode03|192.168.10.14|data
4|datanode04|192.168.10.15|data
5|datanode05|192.168.10.16|master
6|datanode06|192.168.10.17|master
7|datanode07|192.168.10.18|master

# 3 软件版本
- CentOS 64位 6.5版本
- JDK 1.8.0_121
- ElasticSearch 5.2.2
- Kibana 5.2.2


# 4 添加用户
用独立的用户跑es，不要用root

```shell
useradd -s /bin/bash -m qzt_es5
su - qzt_es5
# 创建一个存放安装包的文件夹
mkdir /home/qzt_es5/software
```

# 5 部署JDK
操作系统可能已经有某个版本的jdk，不用它，我们单独部署一个，以免影响系统的其它用户。

从官网下载当前最新的jdk，当前最新为1.8.0_121

```shell
su - qzt_es5
cd /home/qzt_es5/software
tar zxvf jdk-8u121-linux-x64.tar.gz
mv jdk1.8_121 ../
# 修改bash_profile
cd ~
vi bash_profile
# 在文件最后追加如下内容
export JAVA_HOME=/home/qzt_es5/jdk1.8.0_121
export CLASSPATH=$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH:$HOME/bin
# 退出当前用户重新登录，检查jdk版本是否正确
java -version
```
# 6 部署ES

## 6.1 解压部署安装包
下载官网的压缩包，解压，配置es

```shell
cd /home/qzt_es5/software
tar -xvf elasticsearch-5.2.1.tar.gz
mv elasticsearch-5.2.1 ../
# 默认的配置文件在/home/qzt_es5/elasticsearch-5.2.1/config，为方便以后升级，我们需要把配置文件拿出来
cd /home/qzt_es5
mkdir config
# 三个配置文件如下在6.2详细说明
```

## 6.2配置文件

## 6.2.1 elasticsearch.yml
不废话，直接上配置文件内容

```shell
# ======================== Elasticsearch Configuration =========================
#
# NOTE: Elasticsearch comes with reasonable defaults for most settings.
#       Before you set out to tweak and tune the configuration, make sure you
#       understand what are you trying to accomplish and the consequences.
#
# The primary way of configuring a node is via this file. This template lists
# the most important settings you may want to configure for a production cluster.
#
# Please consult the documentation for further information on configuration options:
# https://www.elastic.co/guide/en/elasticsearch/reference/index.html
#
# ---------------------------------- Cluster -----------------------------------
#
# Use a descriptive name for your cluster:
#
# 集群名称
cluster.name: qzt360-es5
#
# ------------------------------------ Node ------------------------------------
#
# Use a descriptive name for the node:
#
# node节点名称
node.name: node-01
#
# Add custom attributes to the node:
#
# 自定义属性，比如在哪个机架上
node.attr.rack: datanode01
#
# ----------------------------------- Paths ------------------------------------
#
# Path to directory where to store the data (separate multiple locations by comma):
#
# 存储数据的目录，不要放在程序包目录内，方便以后升级
path.data: /home/qzt_es5/data
#
# Path to log files:
#
# 日志存储目录
path.logs: /home/qzt_es5/logs
#
# ----------------------------------- Memory -----------------------------------
#
# Lock the memory on startup:
#
# 安装系统的时候就要把交换分区设置为0，因为es碰到内存swapping时，性能极差
bootstrap.memory_lock: true
#
# Make sure that the heap size is set to about half the memory available
# on the system and that the owner of the process is allowed to use this
# limit.
#
# Elasticsearch performs poorly when the system is swapping the memory.
#
# ---------------------------------- Network -----------------------------------
#
# Set the bind address to a specific IP (IPv4 or IPv6):
#
network.host: 192.168.10.12
#
# Set a custom port for HTTP:
#
#http.port: 9200
#
# For more information, consult the network module documentation.
#
# --------------------------------- Discovery ----------------------------------
#
# Pass an initial list of hosts to perform discovery when new node is started:
# The default list of hosts is ["127.0.0.1", "[::1]"]
#
# 发送广播的ip，默认情况下向elasticsearch所在网段的所以ip进行广播
discovery.zen.ping.unicast.hosts: ["192.168.10.12", "192.168.10.13", "192.168.10.14", "192.168.10.15", "192.168.10.16", "192.168.10.17", "192.168.10.18"]
#
# Prevent the "split brain" by configuring the majority of nodes (total number of master-eligible nodes / 2 + 1):
#
# 配置了三个master，3/2+1=2，允许有一个master挂掉
discovery.zen.minimum_master_nodes: 2
#
# For more information, consult the zen discovery module documentation.
#
# ---------------------------------- Gateway -----------------------------------
#
# Block initial recovery after a full cluster restart until N nodes are started:
#
# 只有四个节点都活着才恢复数据
gateway.recover_after_nodes: 4
#
# For more information, consult the gateway module documentation.
#
# ---------------------------------- Various -----------------------------------
#
# Require explicit names when deleting indices:
#
# 删除索引时必须明确提供索引名，设置为true，不允许DELETE /twitt*，相对比较安全，以防误操作
action.destructive_requires_name: true
# node
# 
node.master: true
node.data: false
```

## 6.2.2 jvm.options

```shell
## JVM configuration

################################################################
## IMPORTANT: JVM heap size
################################################################
##
## You should always set the min and max JVM heap
## size to the same value. For example, to set
## the heap to 4 GB, set:
##
## -Xms4g
## -Xmx4g
##
## See https://www.elastic.co/guide/en/elasticsearch/reference/current/heap-size.html
## for more information
##
################################################################

# Xms represents the initial size of total heap space
# Xmx represents the maximum size of total heap space

-Xms2g
-Xmx2g

################################################################
## Expert settings
################################################################
##
## All settings below this section are considered
## expert settings. Don't tamper with them unless
## you understand what you are doing
##
################################################################

## GC configuration
-XX:+UseConcMarkSweepGC
-XX:CMSInitiatingOccupancyFraction=75
-XX:+UseCMSInitiatingOccupancyOnly

## optimizations

# disable calls to System#gc
-XX:+DisableExplicitGC

# pre-touch memory pages used by the JVM during initialization
-XX:+AlwaysPreTouch

## basic

# force the server VM (remove on 32-bit client JVMs)
-server

# explicitly set the stack size (reduce to 320k on 32-bit client JVMs)
-Xss1m

# set to headless, just in case
-Djava.awt.headless=true

# ensure UTF-8 encoding by default (e.g. filenames)
-Dfile.encoding=UTF-8

# use our provided JNA always versus the system one
-Djna.nosys=true

# use old-style file permissions on JDK9
-Djdk.io.permissionsUseCanonicalPath=true

# flags to configure Netty
-Dio.netty.noUnsafe=true
-Dio.netty.noKeySetOptimization=true
-Dio.netty.recycler.maxCapacityPerThread=0

# log4j 2
-Dlog4j.shutdownHookEnabled=false
-Dlog4j2.disable.jmx=true
-Dlog4j.skipJansi=true

## heap dumps

# generate a heap dump when an allocation from the Java heap fails
# heap dumps are created in the working directory of the JVM
-XX:+HeapDumpOnOutOfMemoryError

# specify an alternative path for heap dumps
# ensure the directory exists and has sufficient space
#-XX:HeapDumpPath=${heap.dump.path}

## GC logging

#-XX:+PrintGCDetails
#-XX:+PrintGCTimeStamps
#-XX:+PrintGCDateStamps
#-XX:+PrintClassHistogram
#-XX:+PrintTenuringDistribution
#-XX:+PrintGCApplicationStoppedTime

# log GC status to a file with time stamps
# ensure the directory exists
#-Xloggc:${loggc}

# Elasticsearch 5.0.0 will throw an exception on unquoted field names in JSON.
# If documents were already indexed with unquoted fields in a previous version
# of Elasticsearch, some operations may throw errors.
#
# WARNING: This option will be removed in Elasticsearch 6.0.0 and is provided
# only for migration purposes.
#-Delasticsearch.json.allow_unquoted_field_names=true

```

## 6.2.3 log4j2.properties

```shell
status = error

# log action execution errors for easier debugging
logger.action.name = org.elasticsearch.action
logger.action.level = debug

appender.console.type = Console
appender.console.name = console
appender.console.layout.type = PatternLayout
appender.console.layout.pattern = [%d{ISO8601}][%-5p][%-25c{1.}] %marker%m%n

appender.rolling.type = RollingFile
appender.rolling.name = rolling
appender.rolling.fileName = ${sys:es.logs}.log
appender.rolling.layout.type = PatternLayout
appender.rolling.layout.pattern = [%d{ISO8601}][%-5p][%-25c{1.}] %marker%.-10000m%n
appender.rolling.filePattern = ${sys:es.logs}-%d{yyyy-MM-dd}.log
appender.rolling.policies.type = Policies
appender.rolling.policies.time.type = TimeBasedTriggeringPolicy
appender.rolling.policies.time.interval = 1
appender.rolling.policies.time.modulate = true

rootLogger.level = info
rootLogger.appenderRef.console.ref = console
rootLogger.appenderRef.rolling.ref = rolling

appender.deprecation_rolling.type = RollingFile
appender.deprecation_rolling.name = deprecation_rolling
appender.deprecation_rolling.fileName = ${sys:es.logs}_deprecation.log
appender.deprecation_rolling.layout.type = PatternLayout
appender.deprecation_rolling.layout.pattern = [%d{ISO8601}][%-5p][%-25c{1.}] %marker%.-10000m%n
appender.deprecation_rolling.filePattern = ${sys:es.logs}_deprecation-%i.log.gz
appender.deprecation_rolling.policies.type = Policies
appender.deprecation_rolling.policies.size.type = SizeBasedTriggeringPolicy
appender.deprecation_rolling.policies.size.size = 1GB
appender.deprecation_rolling.strategy.type = DefaultRolloverStrategy
appender.deprecation_rolling.strategy.max = 4

logger.deprecation.name = org.elasticsearch.deprecation
logger.deprecation.level = warn
logger.deprecation.appenderRef.deprecation_rolling.ref = deprecation_rolling
logger.deprecation.additivity = false

appender.index_search_slowlog_rolling.type = RollingFile
appender.index_search_slowlog_rolling.name = index_search_slowlog_rolling
appender.index_search_slowlog_rolling.fileName = ${sys:es.logs}_index_search_slowlog.log
appender.index_search_slowlog_rolling.layout.type = PatternLayout
appender.index_search_slowlog_rolling.layout.pattern = [%d{ISO8601}][%-5p][%-25c] %marker%.-10000m%n
appender.index_search_slowlog_rolling.filePattern = ${sys:es.logs}_index_search_slowlog-%d{yyyy-MM-dd}.log
appender.index_search_slowlog_rolling.policies.type = Policies
appender.index_search_slowlog_rolling.policies.time.type = TimeBasedTriggeringPolicy
appender.index_search_slowlog_rolling.policies.time.interval = 1
appender.index_search_slowlog_rolling.policies.time.modulate = true

logger.index_search_slowlog_rolling.name = index.search.slowlog
logger.index_search_slowlog_rolling.level = trace
logger.index_search_slowlog_rolling.appenderRef.index_search_slowlog_rolling.ref = index_search_slowlog_rolling
logger.index_search_slowlog_rolling.additivity = false

appender.index_indexing_slowlog_rolling.type = RollingFile
appender.index_indexing_slowlog_rolling.name = index_indexing_slowlog_rolling
appender.index_indexing_slowlog_rolling.fileName = ${sys:es.logs}_index_indexing_slowlog.log
appender.index_indexing_slowlog_rolling.layout.type = PatternLayout
appender.index_indexing_slowlog_rolling.layout.pattern = [%d{ISO8601}][%-5p][%-25c] %marker%.-10000m%n
appender.index_indexing_slowlog_rolling.filePattern = ${sys:es.logs}_index_indexing_slowlog-%d{yyyy-MM-dd}.log
appender.index_indexing_slowlog_rolling.policies.type = Policies
appender.index_indexing_slowlog_rolling.policies.time.type = TimeBasedTriggeringPolicy
appender.index_indexing_slowlog_rolling.policies.time.interval = 1
appender.index_indexing_slowlog_rolling.policies.time.modulate = true

logger.index_indexing_slowlog.name = index.indexing.slowlog.index
logger.index_indexing_slowlog.level = trace
logger.index_indexing_slowlog.appenderRef.index_indexing_slowlog_rolling.ref = index_indexing_slowlog_rolling
logger.index_indexing_slowlog.additivity = false
```

# 7 部署x-pack
引入x-pack可以提高es的数据安全，已将java api连接es的代码完成。

服务器部署程序肯定是脱离互联网的，所以要采用现在安装包的方式安装x-pack

## 7.1 安装命令
```shell
/home/qzt_es5/elasticsearch-5.2.2/bin/elasticsearch-plugin install file:///home/qzt_es5/software/x-pack-5.2.2.zip
/home/qzt_es5/kibana-5.2.2-linux-x86_64/bin/kibana-plugin install file:///home/qzt_es5/software/x-pack-5.2.2.zip
```

# 8 启动ES

## 8.1 启动脚本
启动es需要指定一些参数，脑子记的方式不好，直接写成个脚本比较合理

配置文件/home/qzt_es5/restartES.sh

```shell
#! /bin/bash
kill `cat pid`
sleep 7
/home/qzt_es5/elasticsearch-5.2.2/bin/elasticsearch -Epath.conf=/home/qzt_es5/config/ -d -p pid
echo "ES restart success!"
```

## 8.2 启动前的设置
修改/etc/security/limits.conf

在文件最后增加如下内容

```shell
@qzt_es5	soft	nofile	65536
@qzt_es5	hard	nofile	65536
@qzt_es5	soft	nproc	2048
@qzt_es5	hard	nproc	2048
@qzt_es5	soft	memlock	unlimited
@qzt_es5	hard	memlock	unlimited
```

修改/etc/sysctl.conf

在文件最后增加如下内容

```shell
vm.max_map_count = 262144
```
修改完成以上配置后，重启系统，检查配置是否正确的命令如下

```shell
su - qzt_es5
ulimit -a

# 查看vm.max_map_count
sysctl vm.max_map_count

```

# 9 检查集群状态

```shell
# 检查memory_lock
curl -XGET 'http://192.168.10.12:9200/_nodes?filter_path=**.mlockall'
# 检查文件描述符
GET _nodes/stats/process?filter_path=**.max_file_descriptors
```

# 10 启动kibana

```shell
#!/bin/bash
for i in `ps aux|grep kibana |grep 5.2.2 | awk '{print$2}'`
do
  echo "kill -9 "$i
  kill -9 $i
done
/home/qzt_es/kibana-5.2.2-linux-x64/bin/kibana > /dev/null 2>&1 &
echo "Kibana restart done!"
```