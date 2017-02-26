---
layout: post
title:  "ftp服务性能监测"
date:   2017-02-26 23:44:29 +0800
categories: diary
---

概述
---
ftp服务的性能是否达到了满载，目前我还没找到工具在服务端准确检测，所以用了个笨方法解决，那就是写个客户端真实去访问服务器，看时间开销判断服务器负载情况。

ftp配置优化
---
注意： 如果你发现ftp的login时间开销很大，是由于域名反向解析导致的，需要关掉vsftp的这个功能

```shell
//修改文件
vsftp.conf

reverse_lookup_enable=NO

//重启ftp
／etc/init.d/vsftp restart
```

性能检测代码链接
---
[ftpServerPerformanceMonitor](https://github.com/zgj0315/ftpServerPerformanceMonitor)