---
layout: post
title:  "es mapping"
date:   2017-06-15 14:30:00 +0800
categories: es
---

# 1. 概述
修改es中的mapping

不小心入库了一个新字段，需要删除这个字段，怎么办法？

# 2. 过程演示

```
# 删除一个index
DELETE twitter

# 创建一个index
PUT twitter
{
    "settings" : {
        "number_of_shards" : 3,
        "number_of_replicas" : 1
    }
}

# 查看mapping
GET twitter/_mapping

# 插入数据
PUT twitter/tweet/1
{
    "user" : "kimchy"
}

# 查看mapping
GET twitter/_mapping

# 插入数据
PUT twitter/tweet/2
{
    "age" : 25
}

# 查看所有数据
GET twitter/_search

# 查看mapping
GET twitter/_mapping

# 删除doc
DELETE twitter/tweet/2

# 查看所有数据
GET twitter/_search

# 查看mapping
GET twitter/_mapping

# 更新mapping
PUT twitter/_mapping/tweet 
{
  "properties": {
    "user": {
      "type": "text"
    }
  }
}

# 查看mapping
GET twitter/_mapping

PUT twitter/_mapping/tweet
{
  "properties": {
    "user": {
      "type": "text"
    },
    "age": {
      "type": "text"
    }
  }
}

PUT twitter/tweet/2
{
    "age" : "25"
}

# 查看mapping
GET twitter/_mapping

```

# 3. 结论
无法直接修改mapping中某个字段的数据类型，也无法删除mapping中的某个字段