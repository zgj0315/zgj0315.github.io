---
layout: post
title:  "ElasticSearch-5.2.2部署"
date:   2017-03-09 15:48:00 +0800
categories: es
---

# 概述
所有的研究都是要用于生产环境的，大神们都说，所有的x.x.0的版本尽量不要用，因为bug相对较多，ES在2017年02月28日发布了5.2.2版本，本文档就以这版本为例，部署到服务器上进行部分性能测试和调优。

# 环境
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

# 软件版本
- CentOS 64位 6.5版本
- JDK 1.8.0_121
- ElasticSearch 5.2.2
- Kibana 5.2.2


# 添加用户
用独立的用户跑es，不要用root

```shell
useradd -s /bin/bash -m qzt_es5
su - qzt_es5
# 创建一个存放安装包的文件夹
mkdir /home/qzt_es5/software
```

# 部署JDK
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
# 部署ES

## 解压部署安装包
下载官网的压缩包，解压，配置es

```shell
cd /home/qzt_es5/software
tar -xvf elasticsearch-5.2.1.tar.gz
mv elasticsearch-5.2.1 ../
cd ../elasticsearch-5.2.1/config
```

## elasticsearch.yml

## jvm.options

## log4j2.properties

# 启动ES
```shell
./elasticsearch -Ecluster.name=after90_es -Enode.name=node_after90
```
# 有用的ES命令

## Cluster Health

```shell
# 集群是否活着
curl -XGET 'http://127.0.0.1:9200'
# 集群的状态
curl -XGET 'http://127.0.0.1:9200/_cat/health?v'

# node节点的状态
curl -XGET 'http://127.0.0.1:9200/_cat/nodes?v'
```

## List All Indices
```shell
# index的状态
curl -XGET 'http://127.0.0.1:9200/_cat/indices?v'
```

## Create an Index
```shell
curl -XPUT 'http://127.0.0.1:9200/customer?pretty'
```

## Index and Query a Document
```shell
curl -XPUT 'http://127.0.0.1:9200/customer/external/1?pretty' -d'
{
  "name": "John Doe"
}'

curl -XGET 'http://127.0.0.1:9200/customer/external/1?pretty'
```

## Delete an Index
```shell
curl -XDELETE 'http://127.0.0.1:9200/customer?pretty'
```

## Template
```shell
curl -XGET 'http://127.0.0.1:9200/_template?pretty'
```

# Java API Demo
参照工程[ElasticSearchTest](https://github.com/zgj0315/esTest/tree/es5.2.1)

# x-pack
引入x-pack可以提高es的数据安全，已将java api连接es的代码完成。
## 安装命令
```shell
bin/elasticsearch-plugin install x-pack
bin/kibana-plugin install x-pack
```