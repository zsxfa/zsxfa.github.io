{% macro render(display_toc) %}
  <div class="toggle sidebar-toggle">
    <span class="toggle-line toggle-line-first"></span>
    <span class="toggle-line toggle-line-middle"></span>
    <span class="toggle-line toggle-line-last"></span>
  </div>

  <aside class="sidebar">
    <div class="sidebar-inner">

      {%- set display_toc = page.toc.enable and display_toc %}
      {%- if display_toc %}
        {%- set toc = toc(page.content, { class: "nav", list_number: page.toc.number, max_depth: page.toc.max_depth }) %}
        {%- set display_toc = toc.length > 1 and display_toc %}
      {%- endif %}
	
	  <iframe frameborder="no" border="0" marginwidth="0" marginheight="0" width=330 height=86 src="//music.163.com/outchain/player?type=2&id=28946040&auto=0&height=66"></iframe>
	  

      <ul class="sidebar-nav motion-element">
        <li class="sidebar-nav-toc">
          {{ __('sidebar.toc') }}
        </li>
        <li class="sidebar-nav-overview">
          {{ __('sidebar.overview') }}
        </li>
      </ul>

      <!--noindex-->
      <div class="post-toc-wrap sidebar-panel">
        {%- if display_toc %}
          <div class="post-toc motion-element">{{ toc }}</div>
        {%- endif %}
      </div>
      <!--/noindex-->

      <div class="site-overview-wrap sidebar-panel">
        {{ partial('_partials/sidebar/site-overview.swig', {}, {cache: theme.cache.enable}) }}

        {{- next_inject('sidebar') }}
      </div>

	{% if site.tags.length > 1 %}
		<script type="text/javascript" charset="utf-8" src="/js/tagcloud.js"></script>
		<script type="text/javascript" charset="utf-8" src="/js/tagcanvas.js"></script>
		<div class="widget-wrap">
			<h4 class="widget-title" style="font-size:20px;text-align:center;color:#0080FF;margin:20px 0 0px;">Tag Cloud</h4>
			<div id="myCanvasContainer" class="widget tagcloud" style="font-size:20px;">
				<canvas width="220" height="200" id="resCanvas" style="width=100%">
					{{ list_tags() }}
				</canvas>
			</div>
		</div>
	{% endif %}

      {%- if theme.back2top.enable and theme.back2top.sidebar %}
        <div class="back-to-top motion-element">
          <i class="fa fa-arrow-up"></i>
          <span>0%</span>
        </div>
      {%- endif %}
	  

    </div>
	
	
  </aside>
  
  
  <div id="sidebar-dimmer"></div>
{% endmacro %}
