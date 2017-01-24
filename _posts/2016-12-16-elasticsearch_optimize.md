---
layout: post
title:  "ElasticSearch优化"
date:   2016-12-16 10:46:06 +0800
categories: es
---
ES优化是条漫长的路，如果你不知道如何优化，那就用默认值，默认值已经很快了。如果ES变慢了，主要是看es自己的日志和监测系统瓶颈在哪里，有针对性的调整，这里没有万金油。
# 相关命令
{% highlight shell %}
> 整个集群的状态
> curl -XGET 'http://192.168.36.28:9200/_cluster/health?pretty'
> 某几个index的状态
> curl -XGET 'http://192.168.36.28:9200/_cluster/health/eqp,id_database?pretty'
> 注解
> status
> green 绿灯，所有分片都正确运行，集群非常健康。
> yellow 黄灯，所有主分片都正确运行，但是有副本分片缺失。这种情况意味着 ES 当前还是正常运行的，但是有一定风险。注意，在 Kibana4 的 server 端启动逻辑中，即使是黄灯状态，Kibana 4 也会拒绝启动，死循环等待集群状态变成绿灯后才能继续运行。
> red 红灯，有主分片缺失。这部分数据完全不可用。而考虑到 ES 在写入端是简单的取余算法，轮到这个分片上的数据也会持续写入报错。
> number_of_nodes
> 集群内的总节点数
> number_of_data_nodes
> 集群内的总数据节点数
> active_primary_shards
> 集群内所有索引的主分片总数
> active_shards
> 集群内所有索引的分片总数
> relocating_shards
> 正在迁移中的分片数
> initializing_shards
> 正在初始化的分片数
> unassigned_shards
> 未分配到具体节点上的分片数
> delayed_unassigned_shards
> 延时待分配到具体节点上的分片数
> 所有index列表
> curl -XGET 'http://192.168.36.28:9200/_cat/indices?v'
> shard点状态
> curl -XGET 'http://192.168.36.28:9200/_cat/shards?v'
> 查看模版
> curl -XGET 'http://192.168.36.28:9200/_template'
> 各节点详细信息
> curl -XGET 'http://192.168.36.28:9200/_cat/thread_pool?v'
> curl -XGET 'http://192.168.36.28:9200/_nodes/thread_pool?pretty'
> curl -XGET 'http://192.168.36.28:9200/_nodes/stats?pretty'
> 注解
> 更进一步，如果到 85% 或者 95% 了，估计节点一次 GC 能耗时 10s 以上，甚至可能会发生 OOM 了。
> curl '192.168.36.28:9200/_cat/nodes?v'
> 集群状态
> curl -XGET 'http://192.168.36.28:9200/_cluster/stats?pretty'
> hot threads状态
> 命令
> curl -XGET 'http://192.168.36.28:9200/_nodes/_local/hot_threads?interval=60s'
> 注解
> 该接口会返回在 interval 时长内，该节点消耗资源最多的前三个线程的堆栈情况。这对于性能调优初期，采集现状数据，极为有用。
> 默认的采样间隔是 500ms，一般来说，这个时间范围是不太够的，建议至少 60s 以上。
> 默认的，资源消耗是按照 CPU 来衡量，还可以用 ?type=wait 或者 ?type=block 来查看在等待和堵塞状态的当前线程排名。
{% endhighlight %}
# 重启node
如果需要重启某个node，需要如下操作

{% highlight shell %}
> 查看集群的健康状态
curl -XGET 'http://192.168.36.28:9200/_cluster/health?pretty=true'

curl -XPUT '192.168.36.28:9200/_cluster/settings?pretty' -d'
{
  "transient": {
    "cluster.routing.allocation.enable": "none"
  }
}'

curl -XPOST '192.168.36.28:9200/_flush/synced'

> 重启node

curl -XPUT '192.168.36.28:9200/_cluster/settings?pretty' -d'
{
  "transient": {
    "cluster.routing.allocation.enable": "all"
  }
}'


> 等待集群回复正常
curl -XGET '192.168.36.28:9200/_cat/health?pretty'

curl -XGET '192.168.36.28:9200/_cluster/health?pretty'

curl -XGET '192.168.36.28:9200/_cat/recovery?pretty'


> 查看集群设置
curl -XGET '192.168.36.28:9200/_cluster/settings'

{% endhighlight %}

# master的设置
{% highlight shell %}
curl -XPUT '192.168.36.28:9200/_cluster/settings?pretty' -d'
{
  "transient": {
    "discovery.zen.minimum_master_nodes": 1
  }
}'
{% endhighlight %}