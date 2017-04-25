---
layout: post
title:  "ElasticSearch-5.3.0部署"
date:   2017-04-06 09:08:07 +0800
categories: es
---

# 概述
本文档主要记录研究ES过程中走的路线和遇到的坑。

# 操作系统版本
选择CentOS7.3。是否考虑采用Ubuntu？

不能选redhat，因为版权问题，选择较新的操作系统会提高硬件的利用率，相应的bug会多些。

# 磁盘raid
采用raid0的方式

# 操作系统安装采用最小化安装

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

# Mapping
## Set mapping
```
curl -XDELETE '127.0.0.1:9200/my_index'

curl -XPUT '127.0.0.1:9200/my_index' -d '
{
  "mappings": {
    "user": { 
      "_all":       { "enabled": false  }, 
      "properties": { 
        "title":    { "type": "text"  }, 
        "name":     { "type": "text"  }, 
        "age":      { "type": "integer" }  
      }
    },
    "blogpost": { 
      "_all":       { "enabled": false  }, 
      "properties": { 
        "title":    { "type": "text"  }, 
        "body":     { "type": "text"  }, 
        "user_id":  {
          "type":   "keyword" 
        },
        "created":  {
          "type":   "date", 
          "format": "strict_date_optional_time||epoch_millis"
        }
      }
    }
  }
}
'

curl -XGET '127.0.0.1:9200/my_index/_mapping?pretty'

```
## Field datatypes
### Array datatype
```
curl -XPUT '127.0.0.1:9200/my_index/my_type/1' -d '
{
  "message": "some arrays in this document...",
  "tags":  [ "elasticsearch", "wow" ], 
  "lists": [ 
    {
      "name": "prog_list",
      "description": "programming list"
    },
    {
      "name": "cool_list",
      "description": "cool stuff list"
    }
  ]
}
'

curl -XGET '127.0.0.1:9200/my_index/_mapping?pretty'
curl -XGET '127.0.0.1:9200/my_index/my_type/1?pretty'

curl -XPUT '127.0.0.1:9200/my_index/my_type/2' -d '
{
  "message": "no arrays in this document...",
  "tags":  "elasticsearch",
  "lists": {
    "name": "prog_list",
    "description": "programming list"
  }
}
'
curl -XPUT '127.0.0.1:9200/my_index/my_type/2' -d '{"message": "no arrays in this document...","tags":"elasticsearch","lists": {"name":"prog_list","description": "programming list"}}
'

curl -XGET '127.0.0.1:9200/my_index/_search' -d '
{
  "query": {
    "match": {
      "tags": "elasticsearch" 
    }
  }
}
'
```

### Ip Datatype
```
curl -XGET '127.0.0.1:9200/my_index1/_search?pretty'

```

### Nested datatype
```
curl -XDELETE '127.0.0.1:9200/my_index'

curl -XPUT '127.0.0.1:9200/my_index/my_type/1' -d '
{
  "group" : "fans",
  "user" : [ 
    {
      "first" : "John",
      "last" :  "Smith"
    },
    {
      "first" : "Alice",
      "last" :  "White"
    }
  ]
}
'

curl -XGET '127.0.0.1:9200/my_index/my_type/1?pretty'
curl -XGET '127.0.0.1:9200/my_index/_search' -d '
{
  "query": {
    "bool": {
      "must": [
        { "match": { "user.first": "Alice" }},
        { "match": { "user.last":  "Smith" }}
      ]
    }
  }
}
'

curl -XDELETE '127.0.0.1:9200/my_index'
curl -XPUT '127.0.0.1:9200/my_index' -d '
{
  "mappings": {
    "my_type": {
      "properties": {
        "user": {
          "type": "nested" 
        }
      }
    }
  }
}
'

curl -XPUT '127.0.0.1:9200/my_index/my_type/1' -d '
{
  "group" : "fans",
  "user" : [
    {
      "first" : "John",
      "last" :  "Smith"
    },
    {
      "first" : "Alice",
      "last" :  "White"
    }
  ]
}
'
curl -XGET '127.0.0.1:9200/my_index/my_type/1?pretty'
curl -XGET '127.0.0.1:9200/my_index/_search' -d '
{
  "query": {
    "nested": {
      "path": "user",
      "query": {
        "bool": {
          "must": [
            { "match": { "user.first": "Alice" }},
            { "match": { "user.last":  "Smith" }} 
          ]
        }
      }
    }
  }
}
'

curl -XGET '127.0.0.1:9200/my_index/_search' -d '
{
  "query": {
    "nested": {
      "path": "user",
      "query": {
        "bool": {
          "must": [
            { "match": { "user.first": "Alice" }},
            { "match": { "user.last":  "White" }} 
          ]
        }
      },
      "inner_hits": { 
        "highlight": {
          "fields": {
            "user.first": {}
          }
        }
      }
    }
  }
}
'

curl -XGET '127.0.0.1:9200/my_index/_search' -d '
{
  "query": {
    "nested": {
      "path": "user",
      "query": {
        "bool": {
          "must": [
            { "match": { "user.first": "Alice" }},
            { "match": { "user.last":  "White" }} 
          ]
        }
      }
    }
  }
}
'

```