---
title: hexo个性化设置
date: 2022-02-04 22:54:02
tags: Hexo
categories: 建站小记
---

# hexo个性化设置

补一补之前忘记写的内容...

<!--more-->

## hexo主题配置

[Themes of Hexo](https://hexo.io/themes/)官网提供许多主题模板，可以依照喜好选择，本篇以[Next](https://github.com/next-theme/hexo-theme-next)为例

1. 进入hexo项目文件夹，输入命令

   ```shell
   git clone https://github.com/next-theme/hexo-theme-next themes/next
   ```

2. 打开**站点配置文件**（路径：根目录/_config.yml），添加基本配置并修改主题为Next

   ```shell
   theme: next
   ```

### 菜单设置

1. 默认的菜单只有首页和归档两个，可以添加菜单，打开**主题配置文件**（路径：根目录/themes/next/_config.yml），修改内容，根据需要删除前面注释即可启用

   ```shell
   menu:
     home: / || home                          //首页
     archives: /archives/ || archive          //归档
     #categories: /categories/ || th          //分类
     #tags: /tags/ || tags                    //标签
     #about: /about/ || user                  //关于
     #schedule: /schedule/ || calendar        //日程表
     #sitemap: /sitemap.xml || sitemap        //站点地图
     #commonweal: /404/ || heartbeat          //404
   ```

2. 将菜单设置的注释去掉后，需进行创建，以categories和tags为例，删除menu对应注释后，输入命令

   ```shell
   hexo new page categories（tags等）
   ```

3. 把文章归入分类只需在文章的顶部标题下方添加`categories`字段，即可自动创建分类名并加入对应的分类中

   把文章添加标签只需在文章的顶部标题下方添加`tags`字段，即可自动创建标签名并归入对应的标签中

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/19/1645276037.png)

### 主题样式设置

1. Next主题有多种选择，根据需要删除前面注释即可启用，同样是在/themes/next/_config.yml中配置

   ```shell
   # Schemes
   #scheme: Muse
   #scheme: Mist
   scheme: Pisces
   #scheme: Gemini
   ```

### 侧边栏设置

1. 打开**主题配置文件**找到`sidebar`字段

   ```shell
   sidebar:
   # Sidebar Position - 侧栏位置（只对Pisces | Gemini两种风格有效）
     position: left        //靠左放置
     #position: right      //靠右放置
   
   # Sidebar Display - 侧栏显示时机（只对Muse | Mist两种风格有效）
     #display: post        //默认行为，在文章页面（拥有目录列表）时显示
     display: always       //在所有页面中都显示
     #display: hide        //在所有页面中都隐藏（可以手动展开）
     #display: remove      //完全移除
   
     offset: 12            //文章间距（只对Pisces | Gemini两种风格有效）
   
     b2t: false            //返回顶部按钮（只对Pisces | Gemini两种风格有效）
   
     scrollpercent: true   //返回顶部按钮的百分比
   ```

### 搜索设置

1. 需要安装插件，输入命令

   ```shell
   npm install hexo-generator-searchdb --save
   ```

2. 打开**站点配置文件,根目录/_config.yml**找到`Extensions`在下面添加

   ```shell
   # 搜索
   search:
     path: search.xml
     field: post
     format: html
     limit: 10000
   ```

   打开**主题配置文件**找到`Local search`，将`enable`设置为`true`

   ```shell
   local_search:
     enable: true
   ```

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/19/1645276120.png)

### 添加阅读全文按钮

首页文章显示部分，可以通过再文章中添加`<!--more -->`显示部分，并添加阅读全文按钮

### 本地测试 

1. 输入命令

   ```shell
   hexo c
   hexo g 
   hexo s
   ```

2. 然后就可以在localhost:4000进行本地查看了

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/19/1645276174.png)

## hexo+Typora显示图片问题

### 本地设置

利用Typora编写Markdown文件，构建页面后访问网站存在图片不显示的问题，可通过以下方法解决此问题

- 打开**站点配置文件**修改`post_asset_folder`为`true`

- 打开Typora，点击文件---偏好设置---图像，修改为如下设置

  ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/17/1645097078.png)

- 打开Powershell，输入命令

  ```shell
  npm install hexo-asset-image-for-hexo5 --save
  ```

### Github做图床

具体做法如下：

[免费CDN：jsDelivr+Github 使用方法](https://zhuanlan.zhihu.com/p/76951130)

- 图片保存在github仓库，是有1个G的容量限制的，不过可以创建多个仓库对吧

[这里是jsDelivr的地址](https://github.com/jsdelivr/jsdelivr)现在写这篇文章的时候也是可以用的。

​		到这里，就会发现另一个问题，就是在使用图片的时候需要先上传到GitHub仓库中，然后通过将图片地址变成jsDelivr加速后的地址，就像这样：

```
https://raw.githubusercontent.com/你的用户名/你的仓库名/master/文件路径
https://cdn.jsdelivr.net/gh/你的用户名/你的仓库名/文件路径
```

这个过程其实是很麻烦的...当然是不能容忍，于是就在网上去找一些`简便操作`，发现倒是有很多人写过关于粘贴图片时候返回加速后的链接的内容，不过很多都是七牛云等等...不过还是找到了一个可以在粘贴图片的时候将图片上传到GitHub同时返回jsDelivr的链接地址

项目地址是这个[](https://github.com/treeyh/soc-makedown-pic-picker)实测可用。

当然这个也是需要去安装一个软件[AutoHotkey](https://www.autohotkey.com/download/),这个可以去运行一些windows脚本语言，可以去绑定快捷键完成操作等等...下面就是它的脚本：

```shell
;上传图片github，剪切板markdown
;#==win
;!==Alt
;^==Ctrl
;+==shift
;=====================================================
^+v::
{
	runwait, python {你本地的文件路径}\src\github\github_pic_picker.py, , Hide
	send ^v
	return
}
```

​		配置之后就可以不用麻烦的去拼接地址了！！！

## 添加音乐

1. 在网易云音乐中打开你想要插入的音乐页面，点击 **生成外联播放器**。

2. 在网页中调整好播放器插件后，复制下方的HTML代码。以侧边栏为例，修改**blog\themes\next\layout\\_macro**的**sidebar.swig**文件，添加刚刚复制的外链代码，放在<aside class="sidebar">标签中

   ```xml
   <iframe frameborder="no" border="0" marginwidth="0" marginheight="0" width=330 height=86 src="//music.163.com/outchain/player?type=2&id=28946040&auto=1&height=66"></iframe>
   ```
   
   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/19/1645275973.png)

## 添加动态背景

修改`\themes\next\layout\_layout.swig`

在 `< /body>`之前添加代码(注意不要放在`< /head>`的后面)

```xml
{% if theme.canvas_nest %}
<script type="text/javascript" src="//cdn.bootcss.com/canvas-nest.js/1.0.0/canvas-nest.min.js"></script>
{% endif %}
```

修改配置文件

打开 `/themes/next/_config.yml`,在里面添加如下代码：(可以放在最后面)

```xml
# --------------------------------------------------------------
# background settings
# --------------------------------------------------------------
# add canvas-nest effect
# see detail from https://github.com/hustcc/canvas-nest.js
canvas_nest: true
```

如果想要自定义线条的话，设置如下：

在上一步修改 `_layout.swig`中，把刚才的这些代码：

```xml
{% if theme.canvas_nest %}
<script type="text/javascript" src="//cdn.bootcss.com/canvas-nest.js/1.0.0/canvas-nest.min.js"></script>
{% endif %}
```

改为

```xml
{% if theme.canvas_nest %}
<script type="text/javascript"
color="0,0,255" opacity='0.7' zIndex="-2" count="99" src="//cdn.bootcss.com/canvas-nest.js/1.0.0/canvas-nest.min.js"></script>
{% endif %}
```

### 配置项说明

- `color` ：线条颜色, 默认: `'0,0,0'`；三个数字分别为(R,G,B)
- `opacity`: 线条透明度（0~1）, 默认: `0.5`
- `count`: 线条的总数量, 默认: `150`
- `zIndex:` 背景的z-index属性，css属性用于控制所在层的位置, 默认: `-1`

## 修改文章底部的那个带#号的标签

具体实现方法

修改模板/themes/next/layout/_macro/post.swig，搜索 rel="tag">，将 #{{ tag_indicate }} 换成<i class="fa fa-tag"></i>

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/19/1645275901.png)

## 在每篇文章末尾统一添加“本文结束”标记

在路径 **\themes\next\layout\\_macro** 中新建 **passage-end-tag.swig** 文件,并添加以下内容：

这里的图标名称来自于[FontAwesome icon](http://fontawesome.io/icons/)。

```xml
<div>
    {% if not is_index %}
        <div style="text-align:center;color: #ccc;font-size:14px;">-------------文章结束感谢阅读-------------</div>
    {% endif %}
</div>
```

接着打开**\themes\next\layout\\_macro\post.swig**文件，在post-body 之后， post-footer之前添加

```xml
{% include 'passage-end-tag.swig' %}
```

然后打开主题配置文件（_config.yml),在末尾添加：

```yaml
# 文章末尾添加“本文结束”标记
passage_end_tag:
  enabled: true
```

## 设置网站图标

默认的网站图标是一个N，当然是需要制定一个图了，在网上找到图后，将其放在/themes/next/source/images里面，然后在主题配置文件中修改下图所示图片位置

```yaml
favicon:
  #small: /images/favicon-16x16-next.png
  medium: /images/alien.png
  #apple_touch_icon: /images/apple-touch-icon-next.png
  #safari_pinned_tab: /images/logo.svg
  #android_manifest: /images/manifest.json
  #ms_browserconfig: /images/browserconfig.xml
```

## hexo添加tag cloud

首先执行命令：

```shell
npm install hexo-tag-cloud
```

然后需要你去修改主题的 tagcloud 的模板

1. sidebar中添加：

   找到文件 `next/layout/_macro/sidebar.swig`, 然后添加如下内容。

   ```shell
   {% if site.tags.length > 1 %}
   <script type="text/javascript" charset="utf-8" src="{{ url_for('/js/tagcloud.js') }}"></script>
   <script type="text/javascript" charset="utf-8" src="{{ url_for('/js/tagcanvas.js') }}"></script>
   <div class="widget-wrap">
       <h3 class="widget-title">Tag Cloud</h3>
       <div id="myCanvasContainer" class="widget tagcloud">
           <canvas width="250" height="250" id="resCanvas" style="width:100%">
               {{ list_tags() }}
           </canvas>
       </div>
   </div>
   {% endif %}
   
   {%- if theme.back2top.enable and theme.back2top.sidebar %}...
   ```

2. tag页添加：

   ##### 在themes/next/layout/page.swig中添加代码效果如下：

   ```shell
   {% if site.tags.length > 1 %}
   <script type="text/javascript" charset="utf-8" src="/js/tagcloud.js"></script>
   <script type="text/javascript" charset="utf-8" src="/js/tagcanvas.js"></script>
   <div class="widget-wrap">
      <div id="myCanvasContainer" class="widget tagcloud" style="margin-left: 33%;">
         <canvas width="400" height="400" id="resCanvas" style="width=100%">
              {{ list_tags() }}
         </canvas>
       </div>
   </div>
   {% endif %} 
   {% elif page.type === 'categories' %}...
   ```
   
   效果：
   
   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/20/1645352927.png)

### 自定义

 在博客的根目录，找到`_config.yml`文件，最后添加如下的配置项:

```yaml
# hexo-tag-cloud
tag_cloud:
    textFont: Trebuchet MS, Helvetica
    textColor: '#00f' 
    textHeight: 25
    outlineColor: '#E2E1D1'
    maxSpeed: 0.5
```

> textColor: ‘#00f’ 字体颜色
> textHeight: 25 字体高度，根据部署的效果调整
> maxSpeed: 0.5 文字滚动速度，根据自己喜好调整

## 添加live2d模型

1. 命令行输入 `npm install --save hexo-helper-live2d` 获取插件。、

2. 输入 `npm install [name]` 即可下载相应的模型，将 `[name]` 更换成模型名称即可，更多模型选择[点击获取](https://link.juejin.cn/?target=https%3A%2F%2Fgithub.com%2Fxiazeyu%2Flive2d-widget-models)，各个模型的预览请[访问这里](https://link.juejin.cn/?target=https%3A%2F%2Fhuaji8.top%2Fpost%2Flive2d-plugin-2.0%2F)。

3. 打开站点目录下的 `_config.yml` 文件，添加如下代码：

   ```yaml
   live2d:
       enable: true
       scriptFrom: local
       pluginRootPath: live2dw/ # 插件在站点上的根目录(相对路径)
       pluginJsPath: lib/ # 脚本文件相对与插件根目录路径
       pluginModelPath: assets/ # 模型文件相对与插件根目录路径
       tagMode: false # 标签模式, 是否仅替换 live2dtag标签而非插入到所有页面中
       debug: false
       model:
           use: live2d-widget-model-hijiki # 模型名字
           scale: 1
           hHeadPos: 0.5
           vHeadPos: 0.618
       display:
           superSample: 2
           width: 150  # 显示位置及大小 我设置的250*500
           height: 300
           position: right
           hOffset: 0
           vOffset: -20
       mobile:
           show: false  # 手机显示开关，建议关闭
           scale: 0.5
       react:
           opacityDefault: 0.7 # 模型透明度
           opacityOnHover: 0.2
   ```

4. 我们在`node_modules`目录下面找到`live2d-widget-model-hijiki`这个文件夹，把这个文件夹复制下来 找到我们的`hexo`博客的根目录(因为我们是在根目录的`_config.yml`里添加的配置)新建一个文件夹叫做`live2d_models`，把刚刚我们复制的文件粘贴过来

5. 在配置文件中把`use`后面改成我们复制在`live2d_models`文件夹里面的模型目录名称，这样我们就完成了修改

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/20/1645359445.png)

## 添加鼠标点击效果

### 爱心效果

1. 在 `themes/你选择的主题/source/js` 下新建文件 `heart.js` ，添加：

   ```js
   !(function (e, t, a) {
     function n() {
       c(
         ".heart{width: 10px;height: 10px;position: fixed;background: #f00;transform: rotate(45deg);-webkit-transform: rotate(45deg);-moz-transform: rotate(45deg);}.heart:after,.heart:before{content: '';width: inherit;height: inherit;background: inherit;border-radius: 50%;-webkit-border-radius: 500%;-moz-border-radius: 50%;position: fixed;}.heart:after{top: -5px;}.heart:before{left: -5px;}"
       ),
         o(),
         r();
     }
     function r() {
       for (var e = 0; e < d.length; e++)
         d[e].alpha <= 0
           ? (t.body.removeChild(d[e].el), d.splice(e, 1))
           : (d[e].y--,
             (d[e].scale += 0.004),
             (d[e].alpha -= 0.013),
             (d[e].el.style.cssText =
               "left:" +
               d[e].x +
               "px;top:" +
               d[e].y +
               "px;opacity:" +
               d[e].alpha +
               ";transform:scale(" +
               d[e].scale +
               "," +
               d[e].scale +
               ") rotate(45deg);background:" +
               d[e].color +
               ";z-index:99999"));
       requestAnimationFrame(r);
     }
     function o() {
       var t = "function" == typeof e.onclick && e.onclick;
       e.onclick = function (e) {
         t && t(), i(e);
       };
     }
     function i(e) {
       var a = t.createElement("div");
       (a.className = "heart"),
         d.push({
           el: a,
           x: e.clientX - 5,
           y: e.clientY - 5,
           scale: 1,
           alpha: 1,
           color: s(),
         }),
         t.body.appendChild(a);
     }
     function c(e) {
       var a = t.createElement("style");
       a.type = "text/css";
       try {
         a.appendChild(t.createTextNode(e));
       } catch (t) {
         a.styleSheet.cssText = e;
       }
       t.getElementsByTagName("head")[0].appendChild(a);
     }
     function s() {
       return (
         "rgb(" +
         ~~(255 * Math.random()) +
         "," +
         ~~(255 * Math.random()) +
         "," +
         ~~(255 * Math.random()) +
         ")"
       );
     }
     var d = [];
     (e.requestAnimationFrame = (function () {
       return (
         e.requestAnimationFrame ||
         e.webkitRequestAnimationFrame ||
         e.mozRequestAnimationFrame ||
         e.oRequestAnimationFrame ||
         e.msRequestAnimationFrame ||
         function (e) {
           setTimeout(e, 1e3 / 60);
         }
       );
     })()),
       n();
   })(window, document);
   ```

2. `themes/你选择的主题/layout/_layout.swig`下添加：

   ```html
   <!-- 页面点击小红心 -->
   <script type="text/javascript" src="/js/heart.js"></script>
   ```

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/20/1645359740.png)

### 烟花爆炸效果

1. 在 `themes/你选择的主题/source/js` 下新建文件 `firework.js` ，添加：

   ```javascript
   "use strict";
   function updateCoords(e) {
     (pointerX =
       (e.clientX || e.touches[0].clientX) -
       canvasEl.getBoundingClientRect().left),
       (pointerY =
         e.clientY || e.touches[0].clientY - canvasEl.getBoundingClientRect().top);
   }
   function setParticuleDirection(e) {
     var t = (anime.random(0, 360) * Math.PI) / 180,
       a = anime.random(50, 180),
       n = [-1, 1][anime.random(0, 1)] * a;
     return { x: e.x + n * Math.cos(t), y: e.y + n * Math.sin(t) };
   }
   function createParticule(e, t) {
     var a = {};
     return (
       (a.x = e),
       (a.y = t),
       (a.color = colors[anime.random(0, colors.length - 1)]),
       (a.radius = anime.random(16, 32)),
       (a.endPos = setParticuleDirection(a)),
       (a.draw = function () {
         ctx.beginPath(),
           ctx.arc(a.x, a.y, a.radius, 0, 2 * Math.PI, !0),
           (ctx.fillStyle = a.color),
           ctx.fill();
       }),
       a
     );
   }
   function createCircle(e, t) {
     var a = {};
     return (
       (a.x = e),
       (a.y = t),
       (a.color = "#F00"),
       (a.radius = 0.1),
       (a.alpha = 0.5),
       (a.lineWidth = 6),
       (a.draw = function () {
         (ctx.globalAlpha = a.alpha),
           ctx.beginPath(),
           ctx.arc(a.x, a.y, a.radius, 0, 2 * Math.PI, !0),
           (ctx.lineWidth = a.lineWidth),
           (ctx.strokeStyle = a.color),
           ctx.stroke(),
           (ctx.globalAlpha = 1);
       }),
       a
     );
   }
   function renderParticule(e) {
     for (var t = 0; t < e.animatables.length; t++) {
       e.animatables[t].target.draw();
     }
   }
   function animateParticules(e, t) {
     for (var a = createCircle(e, t), n = [], i = 0; i < numberOfParticules; i++) {
       n.push(createParticule(e, t));
     }
     anime
       .timeline()
       .add({
         targets: n,
         x: function (e) {
           return e.endPos.x;
         },
         y: function (e) {
           return e.endPos.y;
         },
         radius: 0.1,
         duration: anime.random(1200, 1800),
         easing: "easeOutExpo",
         update: renderParticule,
       })
       .add({
         targets: a,
         radius: anime.random(80, 160),
         lineWidth: 0,
         alpha: { value: 0, easing: "linear", duration: anime.random(600, 800) },
         duration: anime.random(1200, 1800),
         easing: "easeOutExpo",
         update: renderParticule,
         offset: 0,
       });
   }
   function debounce(e, t) {
     var a;
     return function () {
       var n = this,
         i = arguments;
       clearTimeout(a),
         (a = setTimeout(function () {
           e.apply(n, i);
         }, t));
     };
   }
   var canvasEl = document.querySelector(".fireworks");
   if (canvasEl) {
     var ctx = canvasEl.getContext("2d"),
       numberOfParticules = 30,
       pointerX = 0,
       pointerY = 0,
       tap = "mousedown",
       colors = ["#FF1461", "#18FF92", "#5A87FF", "#FBF38C"],
       setCanvasSize = debounce(function () {
         (canvasEl.width = 2 * window.innerWidth),
           (canvasEl.height = 2 * window.innerHeight),
           (canvasEl.style.width = window.innerWidth + "px"),
           (canvasEl.style.height = window.innerHeight + "px"),
           canvasEl.getContext("2d").scale(2, 2);
       }, 500),
       render = anime({
         duration: 1 / 0,
         update: function () {
           ctx.clearRect(0, 0, canvasEl.width, canvasEl.height);
         },
       });
     document.addEventListener(
       tap,
       function (e) {
         "sidebar" !== e.target.id &&
           "toggle-sidebar" !== e.target.id &&
           "A" !== e.target.nodeName &&
           "IMG" !== e.target.nodeName &&
           (render.play(), updateCoords(e), animateParticules(pointerX, pointerY));
       },
       !1
     ),
       setCanvasSize(),
       window.addEventListener("resize", setCanvasSize, !1);
   }
   ("use strict");
   function updateCoords(e) {
     (pointerX =
       (e.clientX || e.touches[0].clientX) -
       canvasEl.getBoundingClientRect().left),
       (pointerY =
         e.clientY || e.touches[0].clientY - canvasEl.getBoundingClientRect().top);
   }
   function setParticuleDirection(e) {
     var t = (anime.random(0, 360) * Math.PI) / 180,
       a = anime.random(50, 180),
       n = [-1, 1][anime.random(0, 1)] * a;
     return { x: e.x + n * Math.cos(t), y: e.y + n * Math.sin(t) };
   }
   function createParticule(e, t) {
     var a = {};
     return (
       (a.x = e),
       (a.y = t),
       (a.color = colors[anime.random(0, colors.length - 1)]),
       (a.radius = anime.random(16, 32)),
       (a.endPos = setParticuleDirection(a)),
       (a.draw = function () {
         ctx.beginPath(),
           ctx.arc(a.x, a.y, a.radius, 0, 2 * Math.PI, !0),
           (ctx.fillStyle = a.color),
           ctx.fill();
       }),
       a
     );
   }
   function createCircle(e, t) {
     var a = {};
     return (
       (a.x = e),
       (a.y = t),
       (a.color = "#F00"),
       (a.radius = 0.1),
       (a.alpha = 0.5),
       (a.lineWidth = 6),
       (a.draw = function () {
         (ctx.globalAlpha = a.alpha),
           ctx.beginPath(),
           ctx.arc(a.x, a.y, a.radius, 0, 2 * Math.PI, !0),
           (ctx.lineWidth = a.lineWidth),
           (ctx.strokeStyle = a.color),
           ctx.stroke(),
           (ctx.globalAlpha = 1);
       }),
       a
     );
   }
   function renderParticule(e) {
     for (var t = 0; t < e.animatables.length; t++) {
       e.animatables[t].target.draw();
     }
   }
   function animateParticules(e, t) {
     for (var a = createCircle(e, t), n = [], i = 0; i < numberOfParticules; i++) {
       n.push(createParticule(e, t));
     }
     anime
       .timeline()
       .add({
         targets: n,
         x: function (e) {
           return e.endPos.x;
         },
         y: function (e) {
           return e.endPos.y;
         },
         radius: 0.1,
         duration: anime.random(1200, 1800),
         easing: "easeOutExpo",
         update: renderParticule,
       })
       .add({
         targets: a,
         radius: anime.random(80, 160),
         lineWidth: 0,
         alpha: { value: 0, easing: "linear", duration: anime.random(600, 800) },
         duration: anime.random(1200, 1800),
         easing: "easeOutExpo",
         update: renderParticule,
         offset: 0,
       });
   }
   function debounce(e, t) {
     var a;
     return function () {
       var n = this,
         i = arguments;
       clearTimeout(a),
         (a = setTimeout(function () {
           e.apply(n, i);
         }, t));
     };
   }
   var canvasEl = document.querySelector(".fireworks");
   if (canvasEl) {
     var ctx = canvasEl.getContext("2d"),
       numberOfParticules = 30,
       pointerX = 0,
       pointerY = 0,
       tap = "mousedown",
       colors = ["#FF1461", "#18FF92", "#5A87FF", "#FBF38C"],
       setCanvasSize = debounce(function () {
         (canvasEl.width = 2 * window.innerWidth),
           (canvasEl.height = 2 * window.innerHeight),
           (canvasEl.style.width = window.innerWidth + "px"),
           (canvasEl.style.height = window.innerHeight + "px"),
           canvasEl.getContext("2d").scale(2, 2);
       }, 500),
       render = anime({
         duration: 1 / 0,
         update: function () {
           ctx.clearRect(0, 0, canvasEl.width, canvasEl.height);
         },
       });
     document.addEventListener(
       tap,
       function (e) {
         "sidebar" !== e.target.id &&
           "toggle-sidebar" !== e.target.id &&
           "A" !== e.target.nodeName &&
           "IMG" !== e.target.nodeName &&
           (render.play(), updateCoords(e), animateParticules(pointerX, pointerY));
       },
       !1
     ),
       setCanvasSize(),
       window.addEventListener("resize", setCanvasSize, !1);
   }
   ```

2. 在 `themes/你选择的主题/layout/_layout.swig` 下添加：

   ```html
   <canvas class="fireworks" style="position: fixed;left: 0;top: 0;z-index: 1; pointer-events: none;" ></canvas> 
   <script type="text/javascript" src="//cdn.bootcss.com/animejs/2.2.0/anime.min.js"></script> 
   <script type="text/javascript" src="/js/firework.js"></script>
   ```

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/20/1645361568.png)

## 添加网站运行时间

1. 记录网站运行时间在页脚显示，所以在 `themes/你选择的主题/layout/_partial/footer.swig` 下添加：

   ```html
   <!--添加运行时间-->
   <span id="sitetime"></span>
   <script language=javascript>
   	function siteTime(){
   		window.setTimeout("siteTime()", 1000);
   		var seconds = 1000;
   		var minutes = seconds * 60;
   		var hours = minutes * 60;
   		var days = hours * 24;
   		var years = days * 365;
   		var today = new Date();
   		var todayYear = today.getFullYear();
   		var todayMonth = today.getMonth()+1;
   		var todayDate = today.getDate();
   		var todayHour = today.getHours();
   		var todayMinute = today.getMinutes();
   		var todaySecond = today.getSeconds();
   		/* 
         Date.UTC() -- 返回date对象距世界标准时间(UTC)1970年1月1日午夜之间的毫秒数(时间戳)
         year - 作为date对象的年份，为4位年份值
         month - 0-11之间的整数，做为date对象的月份
         day - 1-31之间的整数，做为date对象的天数
         hours - 0(午夜24点)-23之间的整数，做为date对象的小时数
         minutes - 0-59之间的整数，做为date对象的分钟数
         seconds - 0-59之间的整数，做为date对象的秒数
         microseconds - 0-999之间的整数，做为date对象的毫秒数
        */
   		var t1 = Date.UTC(2022,01,10,20,00,00); //北京时间2018-2-13 00:00:00
   		var t2 = Date.UTC(todayYear,todayMonth,todayDate,todayHour,todayMinute,todaySecond);
   		var diff = t2-t1;
   		var diffYears = Math.floor(diff/years);
   		var diffDays = Math.floor((diff/days)-diffYears*365);
   		var diffHours = Math.floor((diff-(diffYears*365+diffDays)*days)/hours);
   		var diffMinutes = Math.floor((diff-(diffYears*365+diffDays)*days-diffHours*hours)/minutes);
   		var diffSeconds = Math.floor((diff-(diffYears*365+diffDays)*days-diffHours*hours-diffMinutes*minutes)/seconds);
   		document.getElementById("sitetime").innerHTML=" 本站已运行"+/*diffYears+" 年 "+*/diffDays+" 天 "+diffHours+" 小时 "+diffMinutes+" 分钟 "+diffSeconds+" 秒";
   	}
   	siteTime();
   </script>
   <!--// 添加运行时间-->
   ```

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/20/1645361979.png)

## 添加浏览器标题恶搞

1. 在用户切换标签页的时候，更改浏览器标题呼唤用户回归，在 `themes/你选择的主题/source/js` 下新建文件 `funny.js` ，添加：

   ```javascript
   var OriginTitle = document.title;
   var titleTime;
   document.addEventListener('visibilitychange', function () {
       if (document.hidden) {
           //$('[rel="icon"]').attr('href', "/funny.ico");
           document.title = '╭(°A°`)╮ 页面崩溃啦 ~';
           clearTimeout(titleTime);
       }
       else {
           //$('[rel="icon"]').attr('href', "/favicon.ico");
           document.title = '(ฅ>ω<*ฅ) 噫又好啦 ~' + OriginTitle;
           titleTime = setTimeout(function () {
               document.title = OriginTitle;
           }, 2000);
       }
   });
   ```

2. 其中的 `favicon.ico` 为正常显示图标，`funny.ico` 为用户切换后的图标，需要你自己设置

## 博客代码备份

使用 `hexo d` 上传到 Github 的只是编译后的静态文件，博客的代码并没有上传到仓库里。

这样一旦你的博客代码丢失，你就无法继续更新了。

为了避免这种情况，我们要把博客代码也上传到仓库里，最好是上传到同一个仓库。

在本地文件根目录创建 `.gitignore` 文件，若存在修改为:

```xml
.DS_Store
*.log
node_modules/
.deploy*/
public/
db.json
```

在本地文件根目录中初始化 git

```shell
git init
```

创建分支develop

```shell
git checkout -b develop
```

提交到仓库，需要注意的事在提交之前要把themes目录下主题中的 `.git` 文件夹重命名或者删除，不然的话 git 会把主题当做子模块来处理。

```shell
git add .
git commit -m 'init'
```

添加远程仓库

```shell
git remote add origin git@github.com:zsxfa/zsxfa.github.io.git
```

push 到远程分支

```shell
git push origin develop
```

### 在别处使用

首先要克隆下这个项目

```
git clone git@github.com:zsxfa/zsxfa.github.io.git
```

进入博客目录

```
cd zsxfa.github.io.git
```

切换到博客文件分支

```
git checkout -b develop origin/develop
```

安装hexo

```
npm install hexo --save
```

然后编辑、查看

```
hexo g    //编译
hexo s    //浏览器查看 localhost:4000
```

提交 git，若在提交过程中出现 `ERROR Deployer not found: git` 可执行 `npm install hexo-deployer-git --save` 后重新提交。

```
hexo d
```

在写了新 markdown 文件后提交 git

```
git add .
git commit -m '新增博客'
git push origin develop
```

到此，我们以后只要写完博客发布后记得 push 一下就能实现备份了。





















