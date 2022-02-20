---
title: Tor浏览器设置
date: 2022-02-16 11:34:02
tags: Tor 安全 代理 浏览器
categories: Security
---

# Tor浏览器设置

## 是什么

Tor 浏览器使用 Tor 网络保护您的隐私和匿名性。使用 Tor 网络有两个主要好处：

- 您的互联网服务提供商和任何本地的监视者都将无法查看您的连接、跟踪您的网络活动，包括您所访问网站的名称和地址。
- 您使用的网站和服务的运营商以及任何监视它们的人都将看到连接来自 Tor 网络而不是您的互联网IP地址，并且不知道您是谁，除非您明确标识自己。

<!--more-->

**Tor 网络**有世界各地志愿者运行的成千上万的服务器组成。每次 Tor Browser创建一个新的连接，会选择这些服务器中的三个**Tor 中继器**连接到互联网。以这样的方式加密整个网络旅程的每一条线路，使得中继本身并不知道它发送和接收数据的完整路径。

Tor 还会对整个网络采取加密通信。然而，此保护不会扩展到使用未加密通道访问的网站(即不支持HTTPS的网站)。

因为 Tor Browser 隐藏了你和访问网站之间的连接，它允许匿名浏览，并避免网络追踪。有助于绕过网络过滤，以便你可以访问(或发布内容)受到屏蔽的网站。

## 下载地址

- 官网地址：https://www.torproject.org/download/
- Tor 完全使用说明 https://tb-manual.torproject.org/zh-CN/about/
- GitHub 源码托管 https://github.com/torproject 
- Tor 项目中文页 https://www.torproject.org/zh-CN/
- **注意:** 如果您所在的地区 Tor Project 的网站被屏蔽，您可以发送邮件获取下载链接，发邮件至**[gettor@torproject.org](mailto:gettor@torproject.org)**，正文中写明你需要的版本(windows, osx 或是 linux)。你将会收到通过Dropbox, Google Docs 或 Github 的Tor Browser 存档链接。有关此功能的更多信息，请参考**[Tor Project website](https://www.torproject.org/)**.

## 说明

Tor 是一个由虚拟通道组成的网络，使您可以提高自己在互联网上的隐私和安全性。Tor 会将您的流量通过 Tor 网络内的三个随机的服务器（也称节点）发送。链路中的最后一个中继（即“出口节点”）将流量发送到公共互联网。

Tor 的一些特性使得`其匿名性略高于普通浏览器的无痕浏览模式`：参考 [Chrome 无痕浏览的工作原理](https://support.google.com/chrome/answer/7440301?co=GENIE.Platform%3DAndroid&hl=zh-Hans)；以及 Tor 安全设置说明：https://tb-manual.torproject.org/zh-CN/security-settings

访问 https://www.cip.cc/ 或 https://whoer.net/zh查看你的IP；既不是你的真实IP（网络运营商分配的IP），也不是你的代理IP，而是 Tor 的三层叠加的最后一层 IP；

## 配置（前置代理）

1. 下载好后校验不再细说，看这里：https://support.torproject.org/tbb/how-to-verify-signature/

2. 选择网络配置，勾选“我使用代理连接至互联网/ I use a proxy connect to the Internet”，这里也可以使用网桥的方式进行连接，不过只有meek-azure可用(我当前的版本是11.0),速度很慢，所以我这里选择使用一个前置代理

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/16/1644981392.png)

3. 这里的地址填写127.0.0.1，端口可以去查看自己代理本地端口。

4. 如果是V2RayN的话，需要在core设置里面**取消勾选“开启流量监测”**

5. 我这里使用的是WinXray,需要改的地方是在下图所示

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/16/1644981568.png)

   **一定要把Sniffing的Enable的值改为false**。

6. 然后就可以正常连接了，测试连接的方式是可以访问https://check.torproject.org/ 查看效果

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/16/1644981714.png)

   如果你想使用与Tor Project 无关的服务来验证你的 IP 地址，有许多选择。支持*https*加密的如下网站(这意味着服务提供商以外的人难以”伪造”结果)：

   - https://www.iplocation.net/
   - https://www.ip2location.com/

7. 也可以查看整个请求链路经过哪些节点

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/16/1644981837.png)

## 配置文件

修改 TOR 的配置文件，规避不安全国家的节点。

TOR的配置文件名叫torrc，这是一个文本文件，用记事本就可以打开。

在该文件末尾，加入下面这行（ExcludeNodes 表示排除这些国家/地区的节点，strictnode 表示强制执行）。

```shell
ExcludeNodes {cn},{hk},{mo}
strictnodes 1
```

如果不设置 strictnode 1，TOR 客户端首先也会规避 ExcludeNodes 列出的这些国家。但如果 TOR 客户端找不到可用的线路，就会去尝试位于排除列表中的节点。
如果设置了 strictnode 1，即使 TOR 客户端找不到可用的线路，也不会去尝试这些国家的节点。

如果你对安全性的要求比较高，可以把这些国家也列入 TOR 的排除节点列表。

> 北朝鲜 {kp}
> 伊朗 {ir}
> 叙利亚 {sy}
> 巴基斯坦 {pk}
> 古巴 {cu}
> 越南 {vn}



待补充...
