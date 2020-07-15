---
layout: post
title:  "Kafka相关操作"
date:   2017-02-27 17:03:29 +0800
categories: diary
---

# 1. 概述
主要用于学习研究Kafka的相关操作

# 2. kafka本地运行
为了自己测试，肯定是需要一个本地运行环境的，所以，骚年，你的电脑内存要够大。

以下以0.10.2.0为例
## 2.1 Download the code
到官网下载程序文件[kafka_2.11-0.10.2.0.tgz](https://www.apache.org/dyn/closer.cgi?path=/kafka/0.10.2.0/kafka_2.11-0.10.2.0.tgz)

```shell
cd ~/work/software
tar zxvf kafka_2.11-0.10.2.0.tgz
mv kafka_2.11-0.10.2.0 ../
cd ../kafka_2.11-0.10.2.0
```

## 2.2 Start the server
kafka需要zookeeper，所以要先启动zookeeper。

配置文件不用修改，直接按照下面步骤启动即可

### 2.2.1 Start ZooKeeper
```shell
bin/zookeeper-server-start.sh config/zookeeper.properties
```

### 2.2.2 Start Kafka
```shell
bin/kafka-server-start.sh config/server.properties
```

## 2.3 命令行操作Kafka
### 2.3.1 Topic
```shell
# list all topic
bin/kafka-topics.sh --list --zookeeper es3:2181

# create a topic
bin/kafka-topics.sh --create --zookeeper es3:2181 --replication-factor 1 --partitions 1 --topic test

# delete a topic
bin/kafka-topics.sh --delete --zookeeper es3:2181 --topic test

# ttl
kafka-configs --zookeeper es3:2181 --entity-type topics --entity-name bangcle_message_decrypt --alter --add-config retention.ms=432000000

kafka-topics --zookeeper es3:2181 --describe --topic bangcle_message_decrypt
```
### 2.3.2 Message
```shell
# send some message
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test

# dump out message
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
```

# 3 Demo链接
## 3.1 Java
[JavaTest](https://github.com/zgj0315/javaTest)

# 4 TodoList
- [x] 本地运行kafka
- [x] java api demo
- [x] spark streaming demo