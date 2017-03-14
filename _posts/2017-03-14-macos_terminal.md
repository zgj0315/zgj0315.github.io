---
layout: post
title:  "MacOS Terminal"
date:   2017-03-14 10:12:12 +0800
categories: macos
---

Terminal
---

系统自带的终端，ssh到centos服务器上的时候会提示

```shell
shell warning: setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory
```

可以通过以下办法解决

```shell
# 打开配置文件ssh_config
sudo vi /etc/ssh/ssh_config

# 注释掉这一行
# SendEnv LANG LC_*
```