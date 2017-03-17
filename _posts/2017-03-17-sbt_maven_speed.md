---
layout: post
title:  "SBT Maven下载包慢的问题"
date:   2017-03-17 11:28:11 +0800
categories: project
---

sbt下载包慢的问题
---
在~/.sbt/新建一个文件repositories，内容如下：

```shell
[repositories]
local
  nexus-aliyun: http://maven.aliyun.com/nexus/content/groups/public/
```

maven下载包慢的问题
在~/.m2/新建一个文件settings.xml，内容如下：

```shell
<settings>
    <mirrors>
        <mirror>
            <id>nexus-aliyun</id>
            <mirrorOf>*</mirrorOf>
            <name>Nexus aliyun</name>
            <url>http://maven.aliyun.com/nexus/content/groups/public</url>
        </mirror>
    </mirrors>
</settings>
```