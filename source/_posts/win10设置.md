---
title: win10设置
date: 2022-02-15 21:47:22
tags: 命令行 代理
categories: Win10
---

------

<!--more-->

# 命令行设置

## cmd中文乱码解决

## 临时解决方案：

修改cmd窗口字符编码为UTF-8

**命令行中执行：**

> chcp 65001

这两条命令只在当前窗口生效，重启后恢复之前的编码。

## 永久解决方案

1. win+R 输入regedit 进入注册表
2. 找到 HKEY_CURRENT_USER\Console\%SystemRoot%_system32_cmd.exe codepage值改为 936（十进制）或 3a8（十六进制）。

3. 重启cmd后生效
4. 对于Power shell修改同样，只需在第2步修改
%SystemRoot%_system32_WindowsPowerShell_v1.0_powershell.exe 下的项。

### 部分字符编码对应代码：

65001——UTF-8

936——简体中文

950——繁体中文

437——美国/加拿大英语

932——日文

949——韩文

866——俄文

## 给cmd设置代理

1. 这个时候可以先查看一下当前cmd的网络信息，通过curl cip.cc测试

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/15/1644934919.png)

   发现是自己本地的地址

2. 接着再找到自己代理的端口(我这里是1082)在命令行中输入

**cmd命令行:(不用socks5)(临时设置)(也可放置环境变量)**

> set http_proxy=http://127.0.0.1:1082
>
> set https_proxy=http://127.0.0.1:1082

接着再进行测试，发现就是代理后的地址了

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/15/1644935339.png)

### 补充：PowerShell 

```shell
$env:http_proxy="http://127.0.0.1:1080"
$env:https_proxy="http://127.0.0.1:1080"
```















