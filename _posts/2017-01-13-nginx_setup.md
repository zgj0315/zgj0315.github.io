---
layout: post
title:  "Nginx的安装部署"
date:   2017-01-13 10:46:06 +0800
categories: nginx
---
# 概述

对比了apache和nginx，如果项目是纯html，推荐使用nginx。

本文档主要介绍如何部署nginx，非root权限。

## 安装

### 安装需要的依赖包
{% highlight shell %}
su - root
rpm -ivh mpfr-2.4.1-6.el6.x86_64.rpm
rpm -ivh cpp-4.4.7-4.el6.x86_64.rpm
rpm -ivh ppl-0.10.2-11.el6.x86_64.rpm
rpm -ivh cloog-ppl-0.15.7-1.2.el6.x86_64.rpm
rpm -ivh gcc-4.4.7-4.el6.x86_64.rpm
rpm -ivh pcre-7.8-6.el6.x86_64.rpm
rpm -ivh pcre-devel-7.8-6.el6.x86_64.rpm
{% endhighlight %}

### 添加用户
{% highlight shell %}
groupadd nginx
useradd -g nginx -s /bin/bash -m qzt_nginx
{% endhighlight %}

### 准备工作
1. 操作系统red hat或者centos
2. 下载nginx的源码包，选择当前稳定版，(nginx-1.10.2.tar.gz) http://nginx.org/en/download.html

### 编译安装nginx
{% highlight shell %}
su - qzt_nginx
./configure --prefix=/home/qzt_nginx/nginx --user=qzt_nginx --group=nginx --with-http_ssl_module
make
make install
{% endhighlight %}