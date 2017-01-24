---
layout: post
title:  "ElasticSearch命令"
date:   2016-12-12 10:46:06 +0800
categories: es
---
# 概述

es有多猛就不嘚嘚了，本文档描述了使用es过程中会遇到的些问题

# 简写规定
{% highlight shell %}
curl -XGET 'localhost:9200/_count?pretty' -d '
{
    "query": {
        "match_all": {}
    }
}'
简写为：

GET /_count
{
    "query": {
        "match_all": {}
    }
}
{% endhighlight %}

# 相关命令
{% highlight shell %}
#检查集群健康
curl '192.168.36.28:9200/_cat/health?v'
#集群状态
curl '192.168.36.28:9200/_cluster/stats?pretty'
#集群索引健康度
curl '192.168.36.28:9200/_cluster/health/logstash-2016.02.26/?pretty'
#索引统计
curl '192.168.36.28:9200/position/_stats?pretty'
#集群的节点列表
curl '192.168.36.28:9200/_cat/nodes?v'
#列出所有的索引
curl '192.168.36.28:9200/_cat/indices?v'
#搜索
curl '192.168.36.28:9200/logstash-2016.02.26/_search?q=*&pretty'
curl -XPOST '192.168.36.28:9200/logstash-2016.02.26/_search' -d '
{
  "query": { "match_all":{}},
  "from": 10,
  "size": 3,
  "_source": ["message"]
}'
#存储数据
curl -XPUT 'localhost:9200/megacorp/employee/1' -d '
{
    "first_name" : "John",
    "last_name" :  "Smith",
    "age" :        25,
    "about" :      "I love to go rock climbing",
    "interests": [ "sports", "music" ]
}'

curl -XPUT 'localhost:9200/megacorp/employee/2' -d '
{
    "first_name" :  "Jane",
    "last_name" :   "Smith",
    "age" :         32,
    "about" :       "I like to collect rock albums",
    "interests":  [ "music" ]
}'

curl -XPUT 'localhost:9200/megacorp/employee/3' -d '
{
    "first_name" :  "Douglas",
    "last_name" :   "Fir",
    "age" :         35,
    "about":        "I like to build cabinets",
    "interests":  [ "forestry" ]
}'
#简单搜索
curl -XGET 'localhost:9200/megacorp/employee/_search'
curl -XGET 'localhost:9200/megacorp/employee/_search?q=last_name:Smith'
#使用DSL语句查询
curl -XGET 'localhost:9200/megacorp/employee/_search' -d '
{
    "query": {
        "match": {
          "last_name" : "Smith"
        }
    }
}'

{% endhighlight %}