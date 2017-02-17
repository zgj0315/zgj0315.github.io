---
layout: post
title:  "ElasticSearch-5.2.1研究"
date:   2017-02-17 09:08:07 +0800
categories: es
---

# 概述
ElasticSearch的发展速度属实很快，业务上对ES依赖越来越大，对性能要求也与日俱增，据说5.0版本的ES性能比2.0版本有了显著提高。

2017年的情人节，发布了版本5.2.1，多么浪漫的版本，那就从这里开始吧。

本文档主要记录研究ES过程中走的路线和遇到的坑。

# 安装
按照官网的介绍，搭建好自己的jdk环境，下载官网的压缩包，解压，执行启动命令

```shell
java -version
curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.2.1.tar.gz
tar -xvf elasticsearch-5.2.1.tar.gz
cd elasticsearch-5.2.1/bin
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

# Java API Demo
参照工程[ElasticSearchTest](https://github.com/zgj0315/esTest)