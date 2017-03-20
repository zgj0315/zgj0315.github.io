---
layout: post
title:  "Emacs安装ox-twbs插件"
date:   2017-03-21 06:26:11 +0800
categories: emacs
---

# 动机
一直都被李伟嘲笑的巨丑的样式终于有所改善了。

之前一直用emacs自带的org-mode直接导处html文件的形式发布，样式确实很丑，懒得去折腾，也就那么用了好几年。

研究了一晚上，终于找到了一款稍微漂亮些的插件解决样式问题

# 插件安装

```shell
# clone最新的ox-twbs.el
git clone https://github.com/marsmining/ox-twbs.git

# emacs安装插件
M-x package-install-file
# 选择ox-twbs.el文件

# 插件使用
M-x org-twbs-export-to-html
```