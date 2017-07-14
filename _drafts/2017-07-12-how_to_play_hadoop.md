---
layout: post
title:  "大数据入门"
date:   2017-07-12 09:30:29 +0800
categories: diary
---

大数据入门要做的事
---

# 1. 我的认为
我认为从事大数据工作，达到的状态有两种：
1. hadoop生态圈的工具都用过，当业务需要的时候，知道如何选择积木，如何组装积木（架构方向）
2. 很深入的了解算法，知道各种主流的机器学习算法，知道如何调整参数，知道如何验证结果（数据分析方向）

我走的是第一条路，第二条知道些皮毛。

# 2. 入门步骤
1. 花2个小时，搭建scala开发环境(jdk,idea,sbt)，写出hello world
2. 花2个小时，搭建一个本地的spark单机运行环境，通过spark-shell实现word count
3. 花2个小时，用scala写一个job，实现word count，本地idea可以运行这个job
4. 花2个小时，将3导出的jar包，运行在本地的spark环境中

/到此，你已经写简历，出去说会用scala语言开发spark程序，进行数据统计/

5. 想办法有个真正的hadoop集群（可以用很烂的几台机器搭建一个集群，采用cdh搭建最方便），把你的job放上去跑，看看各种监测日志和监测界面，你会对并行计算有更多认识
6. 接下来从新开始另外一个事，流式处理，spark-streaming
7. spark-streaming对接kafka
8. run几个经典的机器学习算法找找感觉
9. 一个重要的东西需要知道:HBase,Zookeeper,HDFS