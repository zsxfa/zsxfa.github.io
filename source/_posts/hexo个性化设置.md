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

### 网易云外链

1. 在网易云音乐中打开你想要插入的音乐页面，点击 **生成外联播放器**。

2. 在网页中调整好播放器插件后，复制下方的HTML代码。以侧边栏为例，修改**blog\themes\next\layout\\_macro**的**sidebar.swig**文件，添加刚刚复制的外链代码，放在<aside class="sidebar">标签中

   ```xml
   <iframe frameborder="no" border="0" marginwidth="0" marginheight="0" width=330 height=86 src="//music.163.com/outchain/player?type=2&id=28946040&auto=1&height=66"></iframe>
   ```
   
   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/19/1645275973.png)
   
   这种网易云音乐外链的方式有很多局限性，因此推荐使用aplayer

### 使用aplayer

Aplayer是一个开源的，网页端的播放器，这是它的[使用文档](https://aplayer.js.org/#/zh-Hans/)，这个播放器可以支持播放本地自定义的音频、歌词、专辑封面等等，但是由于我是想直接使用网络端的歌单，所以直接跳过了这一步，本地使用方法可以直接参考使用文档，写的很详细。

接下来的重头戏是直接使用meting实现网络歌单，我是想在所有页面的固定位置显示这个播放模块，正好aplayer自带的吸底模式(翻译为fixed，有点难理解)符合我的要求，它会始终出现在网页的左下角，配合pjax实现不刷新内容,大赞！

1. 添加依赖

   找到主题的页面布局文件，\themes\next\layout\ _layoout.swig
   首先在body中添加依赖：

   ```html
   <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/aplayer@1.10.1/dist/APlayer.min.css"><!--APlayer的样式-->
   <script src="https://cdn.jsdelivr.net/npm/aplayer@1.10.1/dist/APlayer.min.js"></script><!--APlayer的依赖-->
   <script src="https://cdn.jsdelivr.net/npm/meting@2/dist/Meting.min.js"></script><!--Meting的依赖-->
   ```

2. 这里我们指定了版本，因为meting的新版本和aplayer有奇怪的兼容性问题…
   然后就是使用metingjs了，首先附一个官方的[使用文档](https://github.com/metowolf/MetingJS)，使用方法也非常的简单：

   ```
   <meting-js
   	server="netease"
       type="playlist"
       autoplay=true 
       fixed=true 
       id="7267391672"> 
   </meting-js>
   ```

   - server: 歌单的服务商，比如netease代表网易云，tencent代表qq音乐等等
   - type: 类型，单曲或歌单
   - autoplay: 打开网页自动播放
   - fixed: 使用吸底模式
   - id: 歌单的id，在网页端可以直接查看

3. 保存，重启服务之后发现已经出现了吸底的浮窗

#### pjax的配置

1. 配置完aplayer，接下来就是配置跨页面不刷新了。由于我使用的是next主题，其实next主题已经想到了可能是用的pjax，所以我们只需要安装依赖，并且在config中启用即可。

2. 首先安装依赖

   ```shell
   cd themes/next
   git clone https://github.com/theme-next/theme-next-pjax source/lib/pjax
   ```

3. 然后我们只需要在next的_config.yml中找到pjax选项，将false改为true即可

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/21/1645444404.png)

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

   在themes/next/layout/page.swig中添加代码效果如下：

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
cd zsxfa.github.io
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

## 添加彩色滚动变换字体

在你想要添加彩色滚动变换字体的地方写入以下代码即可，其中文字可自行更改：

```html
<div id="binft"></div>
  <script>
    var binft = function (r) {
      function t() {
        return b[Math.floor(Math.random() * b.length)]
      }  
      function e() {
        return String.fromCharCode(94 * Math.random() + 33)
      }
      function n(r) {
        for (var n = document.createDocumentFragment(), i = 0; r > i; i++) {
          var l = document.createElement("span");
          l.textContent = e(), l.style.color = t(), n.appendChild(l)
        }
        return n
      }
      function i() {
        var t = o[c.skillI];
        c.step ? c.step-- : (c.step = g, c.prefixP < l.length ? (c.prefixP >= 0 && (c.text += l[c.prefixP]), c.prefixP++) : "forward" === c.direction ? c.skillP < t.length ? (c.text += t[c.skillP], c.skillP++) : c.delay ? c.delay-- : (c.direction = "backward", c.delay = a) : c.skillP > 0 ? (c.text = c.text.slice(0, -1), c.skillP--) : (c.skillI = (c.skillI + 1) % o.length, c.direction = "forward")), r.textContent = c.text, r.appendChild(n(c.prefixP < l.length ? Math.min(s, s + c.prefixP) : Math.min(s, t.length - c.skillP))), setTimeout(i, d)
      }
      var l = "",
      o = ["一别都门三改火，天涯踏尽红尘。", "依然一笑作春温。","无波真古井，有节是秋筠。", "惆怅孤帆连夜发，送行淡月微云。","尊前不用翠眉颦。","人生如逆旅，我亦是行人。"].map(function (r) {
      return r + ""
      }),
      a = 2,
      g = 1,
      s = 5,
      d = 75,
      b = ["rgb(110,64,170)", "rgb(150,61,179)", "rgb(191,60,175)", "rgb(228,65,157)", "rgb(254,75,131)", "rgb(255,94,99)", "rgb(255,120,71)", "rgb(251,150,51)", "rgb(226,183,47)", "rgb(198,214,60)", "rgb(175,240,91)", "rgb(127,246,88)", "rgb(82,246,103)", "rgb(48,239,130)", "rgb(29,223,163)", "rgb(26,199,194)", "rgb(35,171,216)", "rgb(54,140,225)", "rgb(76,110,219)", "rgb(96,84,200)"],
      c = {
        text: "",
        prefixP: -s,
        skillI: 0,
        skillP: 0,
        direction: "forward",
        delay: a,
        step: g
      };
      i()
      };
      binft(document.getElementById('binft'));
  </script>
```

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/21/1645432348.png)

## 修改超链接的颜色

打开`\themes\next\source\css\_common\components\post`文件夹下的`post.styl`,添加以下css样式：

```css
.post-body p a {
  color: #00ff00;
  border-bottom: none;
  &:hover {
    color: #fc6423;
    text-decoration: underline;
  }
}
```

其中选择`.post-body` 是为了不影响标题，选择 `p` 是为了不影响首页“阅读全文”的显示样式,颜色可以自己定义。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/21/1645446067.png)

## 文章添加阴影效果

打开`\themes\next\source\css\_common\components\post`文件夹下的`post.styl`,添加以下css样式：

```css
// 主页文章添加阴影效果
 .post {
   margin-top: 0px;
   margin-bottom: 60px;
   padding: 25px;
   -webkit-box-shadow: 0 0 5px rgba(202, 203, 203, .5);
   -moz-box-shadow: 0 0 5px rgba(202, 203, 204, .5);
  }
```

## 在博客底部添加访问量

打开`/themes/next/_config.yml`,找到`busuanzi`，修改为以下参数：

```yaml
busuanzi_count:
  enable: true
  total_visitors: true
  total_visitors_icon: user
  total_views: true
  total_views_icon: eye
```

## 博客标题设置

　　这个相关的设置在`blog/_config.yml`中修改，如下图所示：

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/21/1645447298.png)

## 文章字数、阅读时长统计

打开博客根目录，运行以下命令，安装插件

复制

```shell
npm install hexo-symbols-count-time --save
```

然后修改博客配置文件，在末尾添加以下代码：

复制

```yaml
symbols_count_time:
  symbols: true                # 文章字数统计
  time: true                   # 文章阅读时长
  total_symbols: true          # 站点总字数统计
  total_time: true             # 站点总阅读时长
  exclude_codeblock: false     # 排除代码字数统计
```

　　最后在主题配置文件里面，找到`symbols_count_time`,修改成以下内容：

复制

```yaml
symbols_count_time:
  separated_meta: true     # 是否另起一行（true的话不和发表时间等同一行）
  item_text_post: true     # 首页文章统计数量前是否显示文字描述（本文字数、阅读时长）
  item_text_total: true    # 页面底部统计数量前是否显示文字描述（站点总字数、站点阅读时长）
  awl: 1.5                 # Average Word Length
  wpm: 100                 # Words Per Minute（每分钟阅读词数）
  suffix: mins.
```

## 阅读进度条

在主题配置文件中搜索`reading_progress`，找到如下代码段：

```yaml
# Reading progress bar
reading_progress:
  enable: true
```


将`enable`设为true来启用

## 博客背景动画效果canvas_ribbon

```shell
git clone https://github.com/theme-next/theme-next-canvas-ribbon source/lib/canvas-ribbon
```

在主题配置文件中, 搜索: canvas_nest, 修改为自定义值即可.

```yaml
canvas_nest:
  enable: false
  onmobile: true
  color: "0,0,255"
  opacity: 0.5
  zIndex: -1
  count: 99

three:
  enable: false
  delay: false
  three_waves: true
  canvas_lines: true
  canvas_sphere: true

canvas_ribbon:
  enable: true
  size: 300
  alpha: 0.6
  zIndex: -1
```

## 内容里的代码块新增复制按钮

主题配置文件中

```yaml
codeblock:
  copy_button:
    enable: false      # 增加复制按钮的开关
    show_result: false # 点击复制完后是否显示 复制成功 结果提示
```

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/21/1645453024.png)

## 文章原创申明

```yaml
creative_commons:
  license: by-nc-sa
  sidebar: false
  post: true       # 默认显示版权信息
  language:
```

## 添加背景图片

设置背景图片
将想要的背景图片放入` themes/next/source/images`。打开` themes/next/source/css/ _custom/custom.styl` 文件，这个是 Next 故意留给用户自己个性化定制一些样式的文件，添加以下代码即可：

```css
body {
    background:url(/images/yourbackground.jpg);
    background-repeat: no-repeat;
    background-attachment:fixed; //不重复
    background-size: cover;      //填充
    background-position:50% 50%;
}
```

background:url 为图片路径，也可以直接使用链接。
background-repeat：若果背景图片不能全屏，那么是否平铺显示，充满屏幕
background-attachment：背景是否随着网页上下滚动而滚动，fixed 为固定
background-size：图片展示大小，这里设置 100%，100% 的意义为：如果背景图片不能全屏，那么是否通过拉伸的方式将背景强制拉伸至全屏显示。

## 博客内容透明化

NexT 主题的博客文章均是不透明的，这样读者就不能好好欣赏背景图片了，下面的方法可以使博客内容透明化：

在 `themes/next/source/css/_custom/custom.styl` 中添加以下内容：

```css
//博客内容透明化
//文章内容的透明度设置
.content-wrap {
  opacity: 0.9;
}
.content {
	border-radius: 20px; //文章背景设置圆角
	padding: 80px 30px 10px 30px;
	background:rgba(255, 255, 255, 0.2) none repeat scroll !important;
}

//侧边框的透明度设置
.sidebar {
  opacity: 0.9;
}

//菜单栏的透明度设置
.header-inner {
  background: rgba(255,255,255,0.9);
}

//搜索框（local-search）的透明度设置
.popup {
  opacity: 0.9;
}

.tag-cloud-tags{
	margin-top: 3%;
}
.tag-cloud a {
	-webkit-box-shadow: 0 1px 3px rgba(0,0,0,.12),
	0 1px 2px rgba(0, 0, 0, .24);
	-moz-box-shadow: 0 1px 3px rgba(0,0,0, .12),
	0 1px 2px rgba(0,0,0, .24);
	box-shadow: 0 1px 3px rgba(0, 0,0 .12),
	0 1px 2px rgba(0,0,0, .24);
	transition: .2s ease-out;
	padding: 2px 10px;
	margin: 8px;
	background: #eee;
	border-bottom: none;
	border-radius: 12px;
	box-shadow: 0 1px 3px #6f42c1, 0 1px 2px #d9534f;
	display: inline-block;
}
.tag-cloud a:hover{
	text-decoration: none;
	background: #64ceaa;
	color: #fff !important;
	-webkit-box-shadow: 0 8px 16px 0 rgba(0,0,0,.2),
	0 6px 20px 0 rgba(0, 0, 0, .19);
	-moz-box-shadow: 0 8px 16px 0 rgba(0,0,0, .2),
	0 6px 20px 0 rgba(0,0,0, .19);
	box-shadow: 0 8px 16px 0 rgba(0, 0,0 .2),
	0 6px 20px 0 rgba(0,0,0, .19);
}
```

注意：其中 header-inner 不能使用 opacity 进行配置。因为 header-inner 包含 header.swig 中的所有内容。若使用 opacity 进行配置，子结点会出很多问题。

无_custom/custom.styl 文件时，在根目录source下创建 _data文件夹创建styles.styl文件加入css代码，主题_config.yml 文件修改：

```yaml
custom_file_path:
  #head: source/_data/head.swig
  #header: source/_data/header.swig
  #sidebar: source/_data/sidebar.swig
  #postMeta: source/_data/post-meta.swig
  #postBodyEnd: source/_data/post-body-end.swig
  #footer: source/_data/footer.swig
  #bodyEnd: source/_data/body-end.swig
  #variable: source/_data/variables.styl
  #mixin: source/_data/mixins.styl
  style: source/_data/styles.styl
```

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/21/1645454150.png)



