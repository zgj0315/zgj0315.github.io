---
layout: post
title:  "Scala语言SBT构建Spark工程"
date:   2017-01-10 02:15:11 +0800
categories: spark
---

起因
===
之前都是采用maven构建的工程，本身也没有什么问题，最近自习看了scala官网，人家推荐sbt构建工程，我是有代码洁癖的，所以有了这篇文章。

build.sbt配置
---
{% highlight shell linenos %}
import sbt.Keys._

lazy val commonSettings = Seq(
  organization := "org.after90",
  version := "0.1.0",
  scalaVersion := "2.10.6"
)

//resolvers += Resolver.mavenLocal
resolvers ++= Seq(
  "cloudera" at "https://repository.cloudera.com/artifactory/cloudera-repos/"
)

val spark = "org.apache.spark" % "spark-core_2.10" % "1.5.0-cdh5.5.0"
val mllib = "org.apache.spark" % "spark-mllib_2.10" % "1.5.0-cdh5.5.0" excludeAll (ExclusionRule(organization = "javax.servlet"))
val hdfs = "org.apache.hadoop" % "hadoop-hdfs" % "2.6.0-cdh5.5.0"  excludeAll (ExclusionRule(organization = "javax.servlet"))
val spark_streaming_kafka = "org.apache.spark" % "spark-streaming-kafka_2.10" % "1.5.0-cdh5.5.0"  excludeAll (ExclusionRule(organization = "javax.servlet"))

lazy val root = (project in file(".")).
  settings(commonSettings: _*).
  settings(
    name := "MLlibTest",
    libraryDependencies += spark,
    libraryDependencies += mllib,
    libraryDependencies += hdfs,
    libraryDependencies += spark_streaming_kafka
  )
{% endhighlight %}

代码示例
---
{% highlight shell linenos %}
package org.after90.spark

/**
  * Created by zhaogj on 30/12/2016.
  * spark-submit --master yarn-cluster --class org.after90.spark.WordCount sbtprojecttest_2.10-0.1.0.jar
  */
import org.apache.spark.{SparkConf, SparkContext}
object WordCount {
  def main(args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("WordCount").setMaster("local[*]")
    val sc = new SparkContext(conf)
    val textRDD = sc.textFile("/Users/zhaogj/tmp/spark/sparkinput.txt")
    println(textRDD.count())
  }
}
{% endhighlight %}

工程示例
---
在github上建立了一个demo工程，可以参照。地址如下：
[mlLibTest](https://github.com/zgj0315/mlLibTest)

sbt下载包慢的问题
---
在~/.sbt/新建一个文件repositories，内容如下：

```shell
[repositories]
local
  nexus-aliyun: http://maven.aliyun.com/nexus/content/groups/public/
```

sbt指定jdk版本
---
你的电脑可能存在多个版本的jdk，但是系统一般采用最新版的，比如我电脑当前是jdk1.8，但是项目中我又想用jdk1.7编译打包啥的，那咋办？

解决办法：

```shenll
# 启动sbt的命令后加参数
sbt -java-home /Library/Java/JavaVirtualMachines/jdk1.7.0_80.jdk/Contents/Home
```