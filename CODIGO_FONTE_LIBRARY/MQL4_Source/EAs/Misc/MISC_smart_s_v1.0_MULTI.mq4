<!DOCTYPE html>
<html  lang="ru">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<link rel="shortcut icon" href="/images/icons/favicons/fav_logo.ico?6" />

<link rel="apple-touch-icon" href="/images/icons/pwa/apple/default.png?8">

<meta http-equiv="content-type" content="text/html; charset=windows-1251" />
<meta name="description" content="��������� � ������������� �������� ��� ������� � ������ ������ � ��������������, ������� ��������� ���������� ������� ��������� �������. �� �����, ����� ������, ������������, �������������, ������ � ������� ������ ���������� � ��������." />


<title>������ | ���������</title>

<noscript><meta http-equiv="refresh" content="0; URL=/badbrowser.php"></noscript>

<link rel="stylesheet" type="text/css" href="/css/al/common.css?52719122845" /><link rel="stylesheet" type="text/css" href="/css/al/base.css?111429436879" /><link rel="stylesheet" type="text/css" href="/css/al/fonts_utf.css?1" /><link rel="stylesheet" type="text/css" href="/css/al/fonts_cnt.css?7802460376" />

<script type="text/javascript">
(function() {
var alertCont;
function trackOldBrowserEvent(event) {
  var xhr = new XMLHttpRequest();
  xhr.open('GET', '/badbrowser_stat.php?act=track&event=' + event);
  xhr.send();
}
function exposeGlobals() {
  window.hideOldBrowser = function() {
    alertCont.remove();
    var date = new Date();
    date.setTime(date.getTime() + (7 * 24 * 60 * 60 * 1000));
    var expiresDate = date.toGMTString();
    var domain = window.locDomain;
    document.cookie = 'remixoldbshown=1; expires=' + expiresDate + '; path=/' + (domain ? '; domain=.' + domain : '') + ';secure';
    trackOldBrowserEvent('hideAlert');
  }
}
function checkOldBrowser() {
  if(!document.body) {
    setTimeout(checkOldBrowser, 100);
    return;
  }
  try {
    if (!('noModule' in HTMLScriptElement.prototype)) {
      exposeGlobals();
      var alert = '<div class="OldBrowser__container" style="width:960px;">  ���������� <a href="/badbrowser.php?source=old_browser_alert" target="_blank">���� �� ���� ���������</a>, ����� ������ ��������� ���� ������� � ����������.  <span class="OldBrowser__close" aria-label="�������"  role="button" onclick="hideOldBrowser();"></span></div>';
      alertCont = document.createElement('div');
      alertCont.className = 'OldBrowser';
      alertCont.id = 'old_browser_wrap';
      alertCont.innerHTML = alert;
      document.body.appendChild(alertCont);
      trackOldBrowserEvent('showAlert');
    }
  } catch(e) {}
}
checkOldBrowser();
})();
var vk = {
  ads_rotate_interval: 120000,
  al: parseInt('4') || 4,
  id: 0,
  intnat: '' ? true : false,
  host: 'vk.com',
  loginDomain: 'https://login.vk.com/',
  lang: 0,
  statsMeta: {"platform":"web2","st":false,"time":1591417376,"hash":"kz4WwzxwtcxY85N0dUdHKXTdBfRmhziQb4RYOG3Dx88"},
  loaderNavSection: '',
  rtl: parseInt('') || 0,
  version: 12644311,
  stDomains: 0,
  stDomain: '',
  wsTransport: 'https://stats.vk-portal.net',
  stExcludedMasks: ["loader_nav","lang"],
  zero: false,
  contlen: 7077,
  loginscheme: 'https',
  ip_h: '6446a1e5e4f4becc1d',
  navPrefix: '/',
  dt: parseInt('0') || 0,
  fs: parseInt('13') || 13,
  ts: 1591417376,
  tz: 10800,
  pd: 0,
  css_dir: '',
  vcost: 7,
  time: [2020, 6, 6, 7, 22, 56],
  sampleUser: -1, spentLastSendTS: new Date().getTime(),
  a11y: 0,
  statusExportHash: '',
  audioAdsConfig: {"_":"_"},
  longViewTestGroup: "every_view",
  cma: 1,
  lpConfig: {
    enabled: 0,
    key: '',
    ts: 0,
    url: '',
    lpstat: 0
  },

  pr_tpl: "<div class=\"pr %cls%\" id=\"%id%\"><div class=\"pr_bt\"><\/div><div class=\"pr_bt\"><\/div><div class=\"pr_bt\"><\/div><\/div>",
  push_hash: '0db5e2a19dfa693ed5',

  audioInlinePlayerTpl: "<div class=\"audio_inline_player _audio_inline_player no_select\">\n  <div class=\"audio_inline_player_right\">\n    <div class=\"audio_inline_player_volume\"><\/div>\n  <\/div>\n  <div class=\"audio_inline_player_left\">\n    <div class=\"audio_inline_player_progress\"><\/div>\n  <\/div>\n<\/div>",

  pe: {"article_poll":1,"vk_apps_svg_qr":1,"upload.send_upload_stat":1,"push_notifier":1,"story_reactions_web":1,"notify_new_events_box":1,"web_ajax_json_object":1,"mini_apps_web_add_to_favorites":1,"mini_apps_web_add_to_menu":1,"cookie_secure_default_true":1,"mvk_new_info_snackbar":1,"stickers_bot_link":1,"apps_promo_share_story":1,"widgets_xdm_same_origin":1,"stickers_money_transfer_suggestions":1,"web2_story_box_enabled":1,"bridge_mobile_story_box_enabled":1,"gifts_stickers_preview_tooltips":1,"easy_market_promote_new_payment":1,"navigation_timespent":1,"mvk_mediascope_counter":1,"market_item_recommendations_view_log":1,"market_item_others_view_log":1,"web_stats_transport_story_view":1,"registration_item_stat":1,"mvk_lazy_static_reload":1,"notifications_view_new":1,"add_from_field_to_docs_box":1,"ads_market_autopromotion_bookmarks_stats":1,"web_stats_stage_url":1,"network_audio_fragment_stalled":1,"mini_apps_web_call_api_form_data":1},
  countryISO: 'RU',
};;vk.rv="24741";;if (!window.constants) { window.constants = {Groups: {
  GROUPS_ADMIN_LEVEL_USER: 0,
  GROUPS_ADMIN_LEVEL_MODERATOR: 1,
  GROUPS_ADMIN_LEVEL_EDITOR: 2,
  GROUPS_ADMIN_LEVEL_ADMINISTRATOR: 3,
  GROUPS_ADMIN_LEVEL_HOST: 4,
  GROUPS_ADMIN_LEVEL_EVENT_CREATOR: 5,
  GROUPS_ADMIN_LEVEL_CREATOR: 6,
  GROUPS_ADMIN_PSEUDO_LEVEL_ADVERTISER: 100
}}; };

window.locDomain = vk.host.match(/[a-zA-Z]+\.[a-zA-Z]+\.?$/)[0];
var _ua = navigator.userAgent.toLowerCase();
if (/opera/i.test(_ua) || !/msie 6/i.test(_ua) || document.domain != locDomain) document.domain = locDomain;
var ___htest = (location.toString().match(/#(.*)/) || {})[1] || '', ___to;
___htest = ___htest.split('#').pop();
if (vk.al != 1 && ___htest.length && ___htest.substr(0, 1) == vk.navPrefix) {
  if (vk.al != 3 || vk.navPrefix != '!') {
    ___to = ___htest.replace(/^(\/|!)/, '');
    if (___to.match(/^([^\?]*\.php|login|mobile|away)([^a-z0-9\.]|$)/)) ___to = '';
    location.replace(location.protocol + '//' + location.host + '/' + ___to);
  }
}

var StaticFiles = {
  'cmodules/web/common_web.js' : {v: '183'},
  'common.css':{v:52719122845},'base.css':{v:111429436879},'fonts_utf.css':{v:1},'fonts_cnt.css':{v:7802460376}
  ,'cmodules/bundles/audioplayer.9371c749adaff53254df.js':{v:'c61e0bb5cf74af29516e'},'cmodules/bundles/common.ecfb9605778713a5732b.js':{v:'1722f05b78c952318d96'},'cmodules/web/common_web.db5505429f0e3bb787c5.js':{v:'54e37560ec6807ba79ed3cb1fe34fb37'},'lang0_0.js': {v: 26523622},'uncommon.css':{v:18357227929},'cmodules/web/css_types.6b4d012ca1669593da7f.js':{v:'53d3e8050c54fd79d9b7'},'cmodules/web/css_types.js':{v:1},'cmodules/web/jobs_devtools_notification.95033627ab9961dca832.js':{v:'f4f44db71cce7f91353246daa6cbdbf4'},'cmodules/web/jobs_devtools_notification.js':{v:1},'cmodules/web/page_layout.a304ae31e1ddbca2ffe4.js':{v:'14c8812cb982f1a3c297'},'cmodules/web/page_layout.js':{v:1},'cmodules/bundles/4060411aa2c063eade7896c7daf24353.683b455b9c4740441adc.js':{v:'7519bffa059a40960aa5'},'cmodules/bundles/2bddcf8eba73bbb0902e1b2f9d33962b.7a534ccb21b729cb117f.js':{v:'eb2a1f6a7c004fd13ab4'},'cmodules/web/ui_common.a282f38e496111476306.js':{v:'f8341c870404d171d7b7ea0025d44495'},'ui_common.js':{v:6},'ui_common.css':{v:13842277194},'cmodules/bundles/f8a3b0b69a90b5305d627c89f0bd674e.d17655bb108a9f6d4537.js':{v:'d7d8444b72f63077f66e'},'cmodules/web/likes.36757ea9305dc2c0d64e.js':{v:'198b7ee750b4401bc560340fb0edec10'},'cmodules/web/likes.js':{v:1},'cmodules/web/grip.b6cc80315164faa4569c.js':{v:'0e9bf9408b7322fe46d621fe15685212'},'cmodules/web/grip.js':{v:1}
}
var abp;
</script>

<link type="text/css" rel="stylesheet" href="/css/al/uncommon.css?18357227929" /><link type="text/css" rel="stylesheet" href="/css/al/ui_common.css?13842277194" /><script type="text/javascript" src="/js/loader_nav12644311_0.js"></script><script type="text/javascript" src="/js/cmodules/bundles/audioplayer.9371c749adaff53254df.js?c61e0bb5cf74af29516e"></script><script type="text/javascript" src="/js/cmodules/bundles/common.ecfb9605778713a5732b.js?1722f05b78c952318d96"></script><script type="text/javascript" src="/js/cmodules/web/common_web.db5505429f0e3bb787c5.js?54e37560ec6807ba79ed3cb1fe34fb37"></script><script type="text/javascript" src="/js/lang0_0.js?26523622"></script><script type="text/javascript" src="/js/lib/px.js?ch=1"></script><script type="text/javascript" src="/js/lib/px.js?ch=2"></script><meta name="robots" content="noindex" /><meta name="google-site-verification" content="CNjLCRpSR2sryzCC4NQKKCL5WnvmBTaag2J_UlTyYeQ" /><meta name="yandex-verification" content="798f8402854bea07" /><script type="text/javascript" src="/js/cmodules/web/css_types.6b4d012ca1669593da7f.js?53d3e8050c54fd79d9b7"></script><script type="text/javascript" src="/js/cmodules/web/jobs_devtools_notification.95033627ab9961dca832.js?f4f44db71cce7f91353246daa6cbdbf4"></script><script type="text/javascript" src="/js/cmodules/web/page_layout.a304ae31e1ddbca2ffe4.js?14c8812cb982f1a3c297"></script><script type="text/javascript" src="/js/cmodules/bundles/4060411aa2c063eade7896c7daf24353.683b455b9c4740441adc.js?7519bffa059a40960aa5"></script><script type="text/javascript" src="/js/cmodules/bundles/2bddcf8eba73bbb0902e1b2f9d33962b.7a534ccb21b729cb117f.js?eb2a1f6a7c004fd13ab4"></script><script type="text/javascript" src="/js/cmodules/web/ui_common.a282f38e496111476306.js?f8341c870404d171d7b7ea0025d44495"></script><script type="text/javascript" src="/js/cmodules/bundles/f8a3b0b69a90b5305d627c89f0bd674e.d17655bb108a9f6d4537.js?d7d8444b72f63077f66e"></script><script type="text/javascript" src="/js/cmodules/web/likes.36757ea9305dc2c0d64e.js?198b7ee750b4401bc560340fb0edec10"></script><script type="text/javascript" src="/js/cmodules/web/grip.b6cc80315164faa4569c.js?0e9bf9408b7322fe46d621fe15685212"></script>

</head>

<body onresize="onBodyResize()" class="mobfixed ">
  <div id="system_msg" class="fixed"></div>
  <div id="utils"></div>

  <div id="layer_bg" class="fixed"></div><div id="layer_wrap" class="scroll_fix_wrap fixed layer_wrap"><div id="layer"></div></div>
  <div id="box_layer_bg" class="fixed"></div><div id="box_layer_wrap" class="scroll_fix_wrap fixed"><div id="box_layer"><div id="box_loader"><div class="pr pr_baw pr_medium" id="box_loader_pr"><div class="pr_bt"></div><div class="pr_bt"></div><div class="pr_bt"></div></div><div class="back"></div></div></div></div>

  <div id="stl_left"></div><div id="stl_side"></div>

  <script type="text/javascript">window.domStarted && domStarted();</script>

  <div class="scroll_fix_wrap _page_wrap" id="page_wrap"><div><div class="scroll_fix">
  

  <div id="page_header_cont" class="page_header_cont">
    <div class="back"></div>
    <div id="page_header_wrap" class="page_header_wrap">
      <a class="top_back_link" href="" id="top_back_link" onclick="if (nav.go(this, event, {back: true}) === false) { showBackLink(); return false; }"></a>
      <div id="page_header" class="p_head p_head_l0" style="width: 960px">
        <div class="content">
          <div id="top_nav" class="head_nav">
  <div class="head_nav_item fl_l"><a class="top_home_link fl_l CovidLogo" href="/" aria-label="�� �������" accesskey="1"  onmouseover="this.className.indexOf(&#39;bugtracker_logo&#39;) === -1 &amp;&amp; bodyNode.className.indexOf(&#39;WideScreenAppPage&#39;) === -1 &amp;&amp; showTooltip(this,
{
  text: &quot;&lt;div class=\&quot;CovidTooltip__logo\&quot;&gt;&lt;\/div&gt;&lt;div class=\&quot;CovidTooltip__title\&quot;&gt;����������� ����&lt;\/div&gt;&lt;div class=\&quot;CovidTooltip__text\&quot;&gt;����� ����, ��������� ��������� �����, ������������� ���������� ������ ���������� &lt;a href=\&quot;\/feed?section=stayhome\&quot; onclick=\&quot;return typeof window.statlogsValueEvent !== &amp;#39;undefined&amp;#39; &amp;amp;&amp;amp; window.statlogsValueEvent(&amp;#39;coronavirus_tooltip_click&amp;#39;, 1) || nav.go(this, event)\&quot;&gt;��������������&lt;\/a&gt;.&lt;\/div&gt;&quot;,
  className: &#39;CovidTooltip&#39;,
  width: 356,
  dir: &#39;top&#39;,
  shift: [0, 0, 6],
  hidedt: 60, showdt: 600,
  hasover: true,
  onShowStart: function() {window.statlogsValueEvent !== &#39;undefined&#39; &amp;&amp; window.statlogsValueEvent(&#39;coronavirus_tooltip_show&#39;, 1)}
})"><div class="top_home_logo"></div><div class="CovidLogo__hashtag ">#���������</div></a></div>
  <div class="head_nav_item fl_l"><div id="ts_wrap" class="ts_wrap" onmouseover="TopSearch.initFriendsList();">
  <input name="disable-autofill" style="display: none;" />
  <input type="text" onmousedown="event.cancelBubble = true;" ontouchstart="event.cancelBubble = true;" class="text ts_input" id="ts_input" autocomplete="off" name="disable-autofill" placeholder="�����" aria-label="�����" />
</div></div>
  <div class="head_nav_item fl_l head_nav_btns"><div id="top_audio_layer_place" class="top_audio_layer_place"></div></div>
  <div class="head_nav_item fl_r"><a class="top_nav_link" href="" id="top_switch_lang" style="display: none;" onclick="ajax.post('al_index.php', {act: 'change_lang', lang_id: 3, hash: 'cc4b288242047722c1' }); return false;">
  Switch to English
</a><a class="top_nav_link" href="/join" id="top_reg_link" style="" onclick="return !showBox('join.php', {act: 'box', from: nav.strLoc}, {}, event)">
  �����������
</a></div>
  <div class="head_nav_item_player"></div>
</div>
<div id="ts_cont_wrap" class="ts_cont_wrap" ontouchstart="event.cancelBubble = true;" onmousedown="event.cancelBubble = true;"></div>
        </div>
      </div>
    </div>
  </div>

  <div id="page_layout" style="width: 960px;">
    <div id="side_bar" class="side_bar fl_l  sticky_top_force" style="">
      <div id="side_bar_inner" class="side_bar_inner">
        <div id="quick_login" class="quick_login">
  <form method="POST" name="login" id="quick_login_form" action="https://login.vk.com/?act=login">
    <input type="hidden" name="act" value="login" />
    <input type="hidden" name="role" value="al_frame" />
    <input type="hidden" name="expire" id="quick_expire_input" value="" />
    <input type="hidden" name="to" id="quick_login_to" value="" />
    <input type="hidden" name="recaptcha" id="quick_recaptcha" value="" />
    <input type="hidden" name="captcha_sid" id="quick_captcha_sid" value="" />
    <input type="hidden" name="captcha_key" id="quick_captcha_key" value="" />
    <input type="hidden" name="_origin" value="https://vk.com" />
    <input type="hidden" name="ip_h" value="6446a1e5e4f4becc1d" />
    <input type="hidden" name="lg_h" value="dcb33f6cd888106db7" />
    <input type="hidden" name="ul" id="quick_login_ul" value="" />
    <div class="label">������� ��� email</div>
    <div class="labeled"><input type="text" name="email" class="dark" id="quick_email" /></div>
    <div class="label">������</div>
    <div class="labeled"><input type="password" name="pass" class="dark" id="quick_pass" onkeyup="toggle('quick_expire', !!this.value);toggle('quick_forgot', !this.value)" /></div>
    <input type="submit" class="submit" />
  </form>
  <button class="quick_login_button flat_button button_wide" id="quick_login_button">�����</button>
  <button class="quick_reg_button flat_button button_wide" id="quick_reg_button" style="" onclick="top.showBox('join.php', {act: 'box', from: nav.strLoc})">�����������</button>
  <div class="clear forgot"><div class="checkbox" id="quick_expire" onclick="checkbox(this);ge('quick_expire_input').value=isChecked(this)?1:'';">����� ���������</div><a id="quick_forgot" class="quick_forgot" href="/restore" target="_top">������ ������?</a></div>
</div>
      </div>
    </div>

    <div id="page_body" class="fl_r " style="width: 795px;">
      
      <div id="wrap_between"></div>
      <div id="wrap3"><div id="wrap2">
  <div id="wrap1">
    <div id="content"><div class="message_page page_block">
  <div class="message_page_title">������</div>
  <div class="message_page_body">
    ������������, ������� ��������� ��������, ������������.
    <button class="flat_button message_page_btn" id="msg_back_button">�����</button>
  </div>
</div></div>
  </div>
</div></div>
    </div>

    <div id="footer_wrap" class="footer_wrap fl_r" style="width: 960px;"><div class="footer_nav" id="bottom_nav">
  <div class="footer_copy"><a href="/about">���������</a> &copy; 2006�2020</div>
  <div class="footer_links">
    <a class="bnav_a" href="/about">� ���������</a>
    <a class="bnav_a" href="/support?act=home" style="display: none;">������</a>
    <a class="bnav_a" href="/terms">�������</a>
    <a class="bnav_a" href="/ads" style="">�������</a>
    
    <a class="bnav_a" href="/dev">�������������</a>
    <a class="bnav_a" href="/jobs" style="display: none;">��������</a>
  </div>
  <div class="footer_lang"><a class="footer_lang_link" onclick="ajax.post('al_index.php', {act: 'change_lang', lang_id: 0, hash: 'cc4b288242047722c1'})">�������</a><a class="footer_lang_link" onclick="ajax.post('al_index.php', {act: 'change_lang', lang_id: 1, hash: 'cc4b288242047722c1'})">���������</a><a class="footer_lang_link" onclick="ajax.post('al_index.php', {act: 'change_lang', lang_id: 3, hash: 'cc4b288242047722c1'})">English</a><a class="footer_lang_link" onclick="if (vk.al) { showBox('lang.php', {act: 'lang_dialog', all: 1}, {params: {dark: true, bodyStyle: 'padding: 0px'}, noreload: true}); } else { changeLang(1); } return false;">��� ����� &raquo;</a></div>
</div>

<div class="footer_bench clear">
  
</div></div>

    <div class="clear"></div>
  </div>
</div></div><noscript><div style="position:absolute;left:-10000px;">
<img src="//top-fwz1.mail.ru/counter?id=2579437;js=na" style="border:0;" height="1" width="1" />
</div></noscript></div>
  <div class="progress" id="global_prg"></div>

  <script type="text/javascript">
    if (parent && parent != window && (browser.msie || browser.opera || browser.mozilla || browser.chrome || browser.safari || browser.iphone)) {
      document.getElementsByTagName('body')[0].innerHTML = '';
    } else {
      window.domReady && domReady();
      updateMoney(0);
initPageLayoutUI();
if (browser.iphone || browser.ipad || browser.ipod) {
  setStyle(bodyNode, {webkitTextSizeAdjust: 'none'});
}var qf = ge('quick_login_form'), ql = ge('quick_login'), qe = ge('quick_email'), qp = ge('quick_pass');
var qlb = ge('quick_login_button'), prgBtn = qlb;

var qinit = function() {
  setTimeout(function() {
    ql.insertBefore(ce('div', {innerHTML: '<iframe class="upload_frame" id="quick_login_frame" name="quick_login_frame"></iframe>'}), qf);
    qf.target = 'quick_login_frame';
    qe.onclick = loginByCredential;
    qp.onclick = loginByCredential;
  }, 1);
}

if (window.top && window.top != window) {
  window.onload = qinit;
} else {
  setTimeout(qinit, 0);
}

qf.onsubmit = function() {
  if (!ge('quick_login_frame')) return false;
  if (!val('quick_login_ul') && !trim(qe.value)) {
    notaBene(qe);
    return false;
  } else if (!trim(qp.value)) {
    notaBene(qp);
    return false;
  }
  lockButton(window.__qfBtn = prgBtn);
  prgBtn = qlb;
  clearTimeout(__qlTimer);
  __qlTimer = setTimeout(loginSubmitError, 30000);
  domFC(domPS(qf)).onload = function() {
    clearTimeout(__qlTimer);
    __qlTimer = setTimeout(loginSubmitError, 2500);
  }
  return true;
}

window.loginSubmitError = function() {
  showFastBox('�������������e', '�� ������ ������ ����������� �� ����������� ����������. ���� ����� ��� ����������, ����� �� ����� ���������� ����������� ������������ ������� ���� � �����. ����������, ��������� ��������� ���� � ������� � ������� � ������������� �������.');
}
window.focusLoginInput = function() {
  scrollToTop(0);
  notaBene('quick_email');
}
window.changeQuickRegButton = function(noShow) {
  window.cur.noquickreg = noShow;
  if (noShow) {
    hide('top_reg_link', 'quick_reg_button');
  } else {
    show('top_reg_link', 'quick_reg_button');
  }
  toggle('top_switch_lang', noShow && window.langConfig && window.langConfig.id != 3);
}
window.submitQuickLoginForm = function(email, pass, opts) {
  setQuickLoginData(email, pass, opts);
  if (opts && opts.prg) prgBtn = opts.prg;
  if (qf.onsubmit()) qf.submit();
}
window.setQuickLoginData = function(email, pass, opts) {
  if (email !== undefined) ge('quick_email').value = email;
  if (pass !== undefined) ge('quick_pass').value = pass;
  var params = opts && opts.params || {};
  each (params, function(i, v) {
    var el = ge('quick_' + i) || ge('quick_login_' + i);;
    if (el) {
      val(el, params[i]);
    } else {
      qf.appendChild(ce('input', {type: 'hidden', name: i, id: 'quick_login_' + i, value: v}));
    }
  });
}
window.loginByCredential = function() {
  if (!browserFeatures.cmaEnabled || !window.submitQuickLoginForm || window._loginByCredOffered) return false;

  _loginByCredOffered = true;
  navigator.credentials.get({
    password: true,
    mediation: 'required'
  }).then(function(cred) {
    if (cred) {
      submitQuickLoginForm(cred.id, cred.password);
      return true;
    } else {
      return false;
    }
  });
}

if (qlb) {
  qlb.onclick = function() { if (qf.onsubmit()) qf.submit(); };
}

if (browser.opera_mobile) show('quick_expire');

if (1) {
  hide('support_link_td', 'top_support_link');
}
var ts_input = ge('ts_input');
if (ts_input) {
  placeholderSetup(ts_input, {back: false, reload: true, phColor: '#8fadc8'});
}
TopSearch.init();;window.shortCurrency && shortCurrency();
window.zNav && setTimeout(zNav.pbind({}, {"queue":1}), 0);
window.handlePageParams && handlePageParams({"id":0,"no_ads":1,"loc":"?act=s&api=1&did=546563745&dl=GI3TKMZZGA3TMMQ%3A1591417331%3A42102bbdca13043a1b&hash=c22501af67cdec2a7b&no_preview=1&oid=246148419","wrap_page":1,"width":960,"width_dec":165,"width_dec_footer":0,"top_home_link_class":"top_home_link fl_l CovidLogo","body_class":"mobfixed ","to":"ZG9jMjQ2MTQ4NDE5XzU0NjU2Mzc0NT9oYXNoPWMyMjUwMWFmNjdjZGVjMmE3YiZkbD1HSTNUS01aWkdBM1RNTVE6MTU5MTQxNzMzMTo0MjEwMmJiZGNhMTMwNDNhMWImYXBpPTEmbm9fcHJldmlldz0x","counters":[],"pvbig":0,"pvdark":1});addEvent(document, 'click', onDocumentClick);
addLangKeys({"global_apps":"����������","global_friends":"������","global_communities":"����������","head_search_results":"���������� ������","global_chats":"�������","global_show_all_results":"�������� ��� ����������","global_news_search_results":"���������� ������ � ��������","global_emoji_cat_recent":"����� ������������","global_emoji_cat_1":"������","global_emoji_cat_2":"�������� � ��������","global_emoji_cat_3":"����� � ����","global_emoji_cat_4":"��� � �������","global_emoji_cat_5":"����� � ����������","global_emoji_cat_6":"����������� � ���������","global_emoji_cat_7":"��������","global_emoji_cat_8":"�������","global_emoji_cat_9":"�����","stories_archive_privacy_info":"������� � ������ ������ ������ ��","stories_remove_warning":"�� ������������� ������ ������� �������?<br>�������� �������� ����� ����������.","stories_remove_from_narrative_warning":"�� ������������� ������ ������� �������? <br>��� ��� �� �������� �� ������.","stories_narrative_remove_warning":"�� ������������� ������ ������� �����?<br>�������� �������� ����� ����������.","stories_remove_confirm":"�������","stories_answer_placeholder":"���� ���������","stories_answer_sent":"��������� ����������","stories_blacklist_title":"������ �� �������","stories_settings":"���������","stories_add_blacklist_title":"������� �� �������","stories_add_blacklist_message":"������������ ��������� � �������, �� ������� �� ����� ������������ � ��������.","stories_add_blacklist_button":"������ �� �������","stories_add_blacklist_message_group":"�� ���������� ����������� ����������, �� ������� �� ����� ������������ � ��������.","stories_remove_from_blacklist_button":"������� � �������","stories_error_cant_load":"�� ������� ��������� �������.","stories_try_again":"����������� ��� ���","stories_error_expired":"������� ����� ���� ����������<br>� ������� 24 ����� ����� ����������","stories_error_deleted":"������� �������","stories_error_private":"����� ����� �������","stories_error_one_time_seen":"������� ������ �� ��������","stories_mask_tooltip":"����������� ��� �����","stories_mask_sent":"����� ���������� �� �������","stories_followed":"�� �����������&#33;","stories_unfollowed":"�� ����������","stories_is_ad":"�������","stories_private_story":"���������<br>�������","stories_expired_story":"�������<br>�������","stories_deleted_story":"�������<br>�������","stories_bad_browser":"������� �� �������������� � ����� ��������","stories_delete_all_replies_confirm":"�� ������������� ������ ������� ��� ������ {name} �� ��������� �����? <br>�������� �������� ����� ����������.","stories_hide_reply_button":"������ �����","stories_reply_hidden":"����� �� ������� �����.","stories_restore":"������������","stories_hide_reply_continue":"���������� ��������","stories_hide_all_replies":["","������ ��� ��� ������ �� ��������� �����","������ ��� � ������ �� ��������� �����"],"stories_reply_add_to_blacklist":"������� � ������ ������","stories_hide_reply_warning":"�� ������������� ������ ������ ���� �����?<br>�������� �������� ����� ����������.","stories_replies_more_button":["","�������� ��� %s �����������","�������� ��� %s ����������","�������� ��� %s ����������"],"stories_all_replies_hidden":"��� ������ ������","stories_ban_confirm":"�� ������������� ������ �������� � ������ ������ {name}?<br>�������� �������� ����� ����������.","stories_banned":"������������ � ������ ������","stories_share":"����������","stories_like":"��������","stories_follow":"�����������","stories_unfollow":"����������","stories_report":"������������","stories_report_sent":"������ ����������","stories_narrative_show":"���������� c����","stories_narrative_bookmark_added":"����� ������� � {link}���������{\/link}","stories_narrative_bookmark_deleted":"����� ����� �� ��������","stories_narrative_edit_button":"������������� �����","stories_narrative_add_bookmark_button":"��������� � ���������","stories_narrative_remove_bookmark_button":"������� �� ��������","stories_narrative_copy_link":"����������� ������","stories_narrative_copy_link_done":"������ �����������","stories_show_hashtag_link":"����� �� �������","stories_go_to_place":"������� � �����","stories_go_to_group":"������� ����������","stories_go_to_profile":"������� �������","stories_go_to_post":"������� � ������","stories_go_to_story":"������� � �������","stories_share_question":"���������� �������","stories_live_ended_title":"������� �� ��������&#33;","stories_live_ended_desc_club":"���������� {name} <br>��������� ����������.","stories_live_ended_desc_user":["","{name} �������� ����������.","{name} ��������� ����������."],"stories_live_ended_open_club":"������� ����������","stories_live_ended_open_user":"������� �������","stories_live_ended_watch_next":"�������� �����","stories_live_N_watching":["","%s ������� ������","%s ������� ������","%s ������� ������"],"stories_live_chat_msg_too_long":"��������� ������� ������� ","stories_questions_title":"������","stories_question_reply":"��������","stories_question_reply_error":"�� �� ������ ��������� ��������� ����� ������������, ��� ��� �� ��������� ���� ���, ������� ����� ��������� ��� ���������.","stories_question_reply_send":"���������","stories_question_reply_placeholder":"�������� ���������...","stories_question_delete":"������� ������","stories_question_author_ban":"�������������","stories_question_author_unban":"�������������� ������","stories_question_author_blocked":"����� ������������","stories_question_author_unblocked":"����� �������������","stories_question_author_report":"������������","stories_question_report_title":"������ �� ������","stories_question_report_send":"���������","stories_question_more":"��������","stories_question_sent":"�� ���������� ������� � {name}","stories_question_reply_box_title":"��������� {name}","stories_question_ask_placeholder":"������� �����...","stories_question_ask_box_title":"������ � ������� {name}","stories_question_report_reason":"������� �������","stories_question_forbidden":"�� �� ������ ���������� �������","stories_audio_add":"�������� � ��� ������","stories_audio_added":"����������� ���������","stories_audio_delete":"������� �����������","stories_audio_deleted":"����������� �������","stories_audio_next_audio":"������� �����","stories_reactions_title":"������� �������","stories_reactions_tooltip_feature":"������� �� ���� �����, ����� ��������� �������","stories_go_to_market_item":"���������","stories_market_access_error_title":"������","stories_market_access_error_text":"������ ����� ����������","stories_groups_feed_block":"����������","stories_settings_box_tab_all":"���","stories_settings_box_tab_separately":"������������ ��������","stories_settings_box_tab_grouped":"���������������","stories_settings_box_search_placeholder":"����� �� �����������","stories_settings_box_put_back":"���������� ���������","stories_groups_grid_title":"������� ���������","stories_go_to_app":"������� � ����������","stories_groups_grid_text":"����� ������� ������� ���������, �� ������� �� ���������","stories_groups_tooltip":"��������� �������, ������� ������ ������ � ����� ������","stories_settings_saved":"��������� ���������","stories_detailed_stats":"��������� ����������","stories_privacy_feedback_hint":"� ��� ��������� ������ � ��������. ��������� � ��������� �����������, ����� ��� ��������.","stories_privacy_empty_views_hint":"������� ������ ������ ��. �������� �� ���������� ����, ����� �������� ������ ����������","stories_go_to_settings":"������� � ���������","stories_stat_counter_off":"����","stories_question_select_public":"��������","stories_question_select_author_only":"����� ������ ������","stories_question_select_anonymous":"��������","stories_question_about_user_tooltip":"<b>��������<\/b><br>{name} ������ ������� ���� ��� ��� ���������� ������.<br><br><b>��� ����� ������<\/b><br>{name} ������ ���� ���, �� �� ������ ������� ��� ��� ���������� ������.<br><br><b>��������<\/b><br>{name} �� ������ ���� ��� � �� ������ ������� ��� ��� ���������� ������.","stories_question_about_group_tooltip":"<b>��������<\/b><br>������������ ���������� ������ ������� ���� ��� ��� ���������� ������.<br><br><b>��� ����� ������<\/b><br>������������ ���������� ������ ���� ���, �� �� ������ ������� ��� ��� ���������� ������.<br><br><b>��������<\/b><br>������������ ���������� �� ������ ���� ��� � �� ������ ������� ��� ��� ���������� ������.","stories_question_about_user_tooltip_without_anon":"<b>��������<\/b><br>{name} ������ ������� ���� ��� ��� ���������� ������.<br><br><b>��� ����� ������<\/b><br>{name} ������ ���� ���, �� �� ������ ������� ��� ��� ���������� ������.","stories_question_about_group_tooltip_without_anon":"<b>��������<\/b><br>������������ ���������� ������ ������� ���� ��� ��� ���������� ������.<br><br><b>��� ����� ������<\/b><br>������������ ���������� ������ ���� ���, �� �� ������ ������� ��� ��� ���������� ������.","stories_voting_show_result":"���������� ����������"}, true);
addLangKeys({"box_close":"�������","calls_add_participants":"�������� ����������","calls_add_participants_to_call":"�������� � ������ ���������� ������","calls_busy":"������","calls_busy_error":"������������ ��� �������������. ����������� �����.","calls_call_to_chat_members":"��������� ���������� ������","calls_callee_is_offline":"�� � ����","calls_chat_busy_error":"�� �� ������ ������ ������ � ���� ������, ������ ��� � ��� ��� ��� ������.","calls_error_no_cam":"��������� ������ � ������.","calls_error_no_cam_and_mic":"��������� ������ � ������ � ���������.","calls_error_no_mic":"��������� ������ � ���������.","calls_flood_error":"�� ������� ����� �������. ��������� ������� �����.","calls_hangup_description":"�� �������, ��� ������ ��������� ������?","calls_incoming_audiocall":"�������� �����������","calls_incoming_process_error":"��� ���������, �� ������� ������ � ������ ��� ���������� �� ��������� ��-�� ������.<br>���������� ������� ����� � ��������� ����������. ���� ��� �� �������, �������� �������� � ��������� ����������� �����������.","calls_incoming_videocall":"�������� �����������","calls_no_camera":"������ �� ����������","calls_privacy_error":"������ �� ������, ��� ��� � ��� ��� ����������� ������ ��������� � ���������� �����������.","calls_reject":"���������","calls_reject_call":"��������� ������","calls_reject_description":"�� �������, ��� ������ ��������� ������?","calls_reject_title":"��������� ������","calls_rejected_status":"����� �������","calls_reply":"��������","calls_reply_with_audio":"�������� ������","calls_reply_with_video":"�������� ������","calls_selected":"������� {selected} �� {limit}","calls_settings":"���������","calls_settings_camera":"������","calls_settings_mic":"��������","calls_settings_no_camera":"������ �� ����������","calls_settings_no_mic":"�������� �� ���������","calls_start_error":"�� ����� ������ ��������� ������. ��������� ������� �����.","calls_status_connecting":"�����������","calls_status_hangup":"����������","calls_status_no_permissions":"��� ����������","calls_status_waiting":"��������","calls_unsupported_browser_error":"������ �� ������, ������ ��� ��� ������� �������. �������� ���, ����� ������������ ��������.","captcha_cancel":"������","captcha_enter_code":"������� ��� � ��������","captcha_send":"���������","global_add":"��������","global_age_days":["","%s ����","%s ���","%s ����"],"global_age_months":["","%s �����","%s ������","%s �������"],"global_age_seconds":["","%s �������","%s �������","%s ������"],"global_age_weeks":["","%s ������","%s ������","%s ������"],"global_age_years":["","%s ���","%s ����","%s ���"],"global_and":"{before} � {after}","global_apps":"����������","global_back":"�����","global_box_title_back":"��������� �����","global_cancel":"������","global_captcha_input_here":"������� ���","global_chats":"�������","global_close":"�������","global_communities":"����������","global_date":["","{day} {month} {year}","�����","�������","������"],"global_days_accusative":["","%s ����","%s ���","%s ����"],"global_delete":"�������","global_error":"������","global_friends":"������","global_hours":["","%s ���","%s ����","%s �����"],"global_hours_accusative":["","%s ���","%s ����","%s �����"],"global_hours_ago":["","%s ��� �����","%s ���� �����","%s ����� �����"],"global_just_now":"������ ���","global_mins_ago":["","%s ������ �����","%s ������ �����","%s ����� �����"],"global_minutes":["","%s ������","%s ������","%s �����"],"global_minutes_accusative":["","%s ������","%s ������","%s �����"],"global_money_amount_rub":["","%s �����","%s �����","%s ������"],"global_months_accusative":["","%s �����","%s ������","%s �������"],"global_news_search_results":"���������� ������ � ��������","global_no":"���","global_online_long_ago":["","������� �����","�������� �����"],"global_online_this_month":["","������� � ���� ������","������� � ���� ������"],"global_online_was_recently":["","������� �������","�������� �������"],"global_online_was_week":["","������� �� ���� ������","�������� �� ���� ������"],"global_recaptcha_title":"������������� ��������","global_save":"���������","global_seconds_accusative":["","%s �������","%s �������","%s ������"],"global_secs_ago":["","%s ������� �����","%s ������� �����","%s ������ �����"],"global_short_date":["","{day} {month}","�����","�������","������"],"global_short_date_time":["","{day} {month} � {hour}:{minute}","����� � {hour}:{minute}","������� � {hour}:{minute}","������ � {hour}:{minute}"],"global_short_date_time_l":["","{day} {month} � {hour}:{minute}","����� � {hour}:{minute}","������� � {hour}:{minute}","������ � {hour}:{minute}"],"global_show_all_results":"�������� ��� ����������","global_sorry_error":"� ���������, ��������� ������","global_to_top":"������","global_user_is_online":"������","global_user_is_online_mobile":"������ � ��������","global_warning":"�������������e","global_weeks_accusative":["","%s ������","%s ������","%s ������"],"global_word_hours_ago":["","��� �����","��� ���� �����","��� ���� �����","������ ���� �����","���� ����� �����"],"global_word_mins_ago":["","������ �����","��� ������ �����","��� ������ �����","4 ������ �����","5 ����� �����"],"global_word_secs_ago":["","������ ���","��� ������� �����","��� ������� �����","������ ������� �����","���� ������ �����"],"global_years_accusative":["","%s ���","%s ����","%s ���"],"global_yes":"��","head_search_results":"���������� ������","mail_ad_tag_no_access_box_text":"������������ ���� � ��������� ��������, ����� ������������� ����������.","mail_ad_tag_no_access_box_title":"������","mail_ad_tag_no_access_text":"�� �������","mail_ad_tag_text_prefix":"AD","mail_added_article":"������","mail_added_artist":"��������","mail_added_audio":"�����������","mail_added_audio_album":"������","mail_added_audio_playlist":"��������","mail_added_audiomsg":"��������� ���������","mail_added_audios":["","�����������","%s �����������","%s ������������"],"mail_added_call":"������","mail_added_clips":"�����","mail_added_doc":"��������","mail_added_docs":"��������","mail_added_geo":"�����","mail_added_gift":"�������","mail_added_graffiti":"��������","mail_added_group":"������","mail_added_link":"������","mail_added_market_item":"�����","mail_added_mask":"�����","mail_added_money_request":"������ �� �������� �������","mail_added_money_transfer":"�������� �������","mail_added_msg":"C��������","mail_added_msgs":"C��������","mail_added_photo":"����������","mail_added_photos":["","����������","%s ����������","%s ����������"],"mail_added_podcast":"�������","mail_added_poll":"�����","mail_added_sticker":"������","mail_added_story":"�������","mail_added_video":"�����������","mail_added_videos":["","�����������","%s �����������","%s ������������"],"mail_added_vkpay":"������ VK Pay","mail_added_wall":"������ �� �����","mail_added_wall_reply":"����������� �� �����","mail_allow_comm_messages":"��������� ���������","mail_and_peer":"� ��� {count} {typing}","mail_and_peer_one":"�","mail_block_comm_messages":"��������� ���������","mail_block_notify_messages":"��������� ����������","mail_block_user":"������������� ������������","mail_by_you":"��","mail_call_canceled":"�� �������� ������","mail_call_declined":"������ �������","mail_call_declined_by":["","{user_name} �������� ������","{user_name} ��������� ������"],"mail_call_incoming":"�������� ������ ({duration})","mail_call_missed":"�� ���������� ������","mail_call_outgoing":"��������� ������ ({duration})","mail_call_snippet_canceled":"������","mail_call_snippet_declined":"�������","mail_call_snippet_incoming":"�������� ������","mail_call_snippet_incoming_video":"�������� �����������","mail_call_snippet_missed":"��������","mail_call_snippet_missed_call":"����������� ������","mail_call_snippet_outgoing":"��������� ������","mail_call_snippet_outgoing_video":"��������� �����������","mail_chat_leave_confirm":"������� ������, �� �� ������ �������� ����� ��������� �� ����������. �� ������� ��������� ��� ������� ��������� ����.<br>","mail_chat_sure_to_delete_all":"�� ������������� ������ <b>������� ��� ���������<\/b> � ���� ������?<br><br>�������� ��� �������� ����� <b>����������<\/b>.","mail_clear_recent":"��������","mail_create_chat_remove_user":"������� �����������","mail_delete":"�������","mail_delete_for_all":"������� ��� ����","mail_deleteall1":"������� ��� ���������","mail_deleted_stop":"��������� �������.","mail_dialog_msg_delete_N":["","�� ������������� ������ <b>�������<\/b> ���������?","�� ������������� ������ <b>�������<\/b> %s ���������?","�� ������������� ������ <b>�������<\/b> %s ���������?"],"mail_dialog_msg_delete_title":"������� ���������","mail_error":"������","mail_expired_message":"��������� �������","mail_fwd_msgs":["","%s ���������","%s ���������","%s ���������"],"mail_gift_message_sent":["","�������� �������","��������� �������"],"mail_group_sure_to_delete_all":"�� ������������� ������ <b>������� ��� ���������<\/b> � ���� �����������?<br><br>�������� ��� �������� ����� <b>����������<\/b>.","mail_header_online_status":"online","mail_hide_unpin_hover":"������","mail_im_call_audio":"�����������","mail_im_call_video":"�����������","mail_im_chat_created":["","{from} ������ ������ {title}","{from} ������� ������ {title}"],"mail_im_chat_own_screenshot":"�� ������� �������� ������","mail_im_chat_screenshot":["","{from} ������ �������� ������","{from} ������� �������� ������"],"mail_im_create_chat_with":"�������� ������������","mail_im_delete_all_history":"�������� ������� ���������","mail_im_delete_email_contact":"������� ���������","mail_im_goto_conversation":"������� � �������","mail_im_group_call_started":["","{from} ����� ��������� ������","{from} ������ ��������� ������"],"mail_im_invite_by_link":["","{from} ������������� � ������ �� ������","{from} �������������� � ������ �� ������"],"mail_im_invited":["","{from} ��������� {user}","{from} ���������� {user}"],"mail_im_kicked_from_chat":["","{from} �������� {user}","{from} ��������� {user}"],"mail_im_left":["","{from} ����� �� ������","{from} ����� �� ������"],"mail_im_mention_all":"��� ��������� ������","mail_im_mention_online":"���, ��� ������ ������","mail_im_mute":"��������� �����������","mail_im_n_chat_members":["","%s ��������","%s ���������","%s ����������"],"mail_im_new_messages":["","%s ����� ���������","%s ����� ���������","%s ����� ���������"],"mail_im_peer_profile_delete_note_success":"����������� �����","mail_im_peer_profile_extra_tags":["","%s �����","%s �����","%s �����"],"mail_im_peer_profile_info_empty":"��� ������","mail_im_peer_profile_info_label_text":"����������:","mail_im_peer_profile_join_date_empty_text":["","�� ��������","�� ���������"],"mail_im_peer_profile_join_date_label_text":"������������:","mail_im_peer_profile_manage_tags":"���������� �������","mail_im_peer_profile_manage_tags_add_link":"�������� �����","mail_im_peer_profile_manage_tags_box_title":"����������","mail_im_peer_profile_manage_tags_placeholder":"����� �����","mail_im_peer_profile_manage_tags_remove":"������� �����","mail_im_peer_profile_manage_tags_success":"����� ���������","mail_im_peer_profile_note_add_link":"�������� �����������","mail_im_peer_profile_note_box_placeholder":"������� �����","mail_im_peer_profile_note_box_title":"����������� ��������������","mail_im_peer_profile_note_delete_confirmation_text":"�� �������, ��� ������ ������� �����������?","mail_im_peer_profile_note_delete_link":"������� �����������","mail_im_peer_profile_note_edit_link":"�������������","mail_im_peer_profile_note_label_text":"�����������:","mail_im_peer_profile_save_note_success":"����������� �������","mail_im_peer_profile_tags_empty":"��� �����","mail_im_peer_profile_tags_label_text":"�����:","mail_im_peer_profile_toggle_tags_off":"������ ��������� �����","mail_im_peer_profile_toggle_tags_on":"�������� ��������� �����","mail_im_peer_search":"����� �� ������� ���������","mail_im_photo_removed":["","{from} ������ ���������� ������","{from} ������� ���������� ������"],"mail_im_photo_removed_channel":["","{from} ������ ���������� ������","{from} ������� ���������� ������"],"mail_im_photo_set":["","{from} ������� ���������� ������","{from} �������� ���������� ������"],"mail_im_pin_message":["","{from} �������� ��������� �{msg}�","{from} ��������� ��������� �{msg}�"],"mail_im_pin_message_empty2":["","{from} �������� {link}���������{\/link}","{from} ��������� {link}���������{\/link}"],"mail_im_returned_to_chat":["","{from} �������� � ������","{from} ��������� � ������"],"mail_im_search_empty":"�� ������� ��������� �� ������ �������.","mail_im_show_media_history":"�������� ��������","mail_im_show_media_history_group":"�������� ��������","mail_im_title_updated_channel":["","{from} ������� �������� ������: {title}","{from} �������� �������� ������: {title}"],"mail_im_title_updated_dot":["","{from} ������� �������� ������: {title}","{from} �������� �������� ������: {title}"],"mail_im_unmute":"�������� �����������","mail_im_unpin_message":["","{from} �������� ��������� �{msg}�","{from} ��������� ��������� �{msg}�"],"mail_im_unpin_message_empty2":["","{from} �������� {link}���������{\/link}","{from} ��������� {link}���������{\/link}"],"mail_invitation_sended_ago":"����������� ���������� {when}","mail_join_invite_error_title":"������ ���������� � ���","mail_keyboard_label_location":"��������� ��� ��������������","mail_keyboard_label_vkpay":"�������� ����� VK Pay","mail_last_activity_tip":["","{user} ��� � ���� {time}","{user} ���� � ���� {time}"],"mail_leave_channel":"���������� �� ������","mail_leave_chat":"����� �� ������","mail_marked_as_spam":"��������� �������� ��� ���� � �������.","mail_menu_pin_hide":"������ �������. ���������","mail_menu_pin_show":"�������� �������. ���������","mail_menu_unpin":"��������� ���������","mail_message_edited":"��������","mail_message_request_reject":"���������","mail_message_wait_until_uploaded":"����������, ��������� ��������� �������� ������.","mail_messages_expired":["","{count} ��������� �������","{count} ��������� �������","{count} ��������� �������"],"mail_money_amount_rub":["","%s ���.","%s ���.","%s ���."],"mail_money_request_collected_amount":"������� {amount}","mail_money_request_collected_amount_from":"������� {amount} �� {total_amount}","mail_money_request_held_amount":"({amount} ������� ���������)","mail_money_request_message_sent":["","�������� ������ �� �������","��������� ������ �� �������"],"mail_money_tranfer_message_sent":["","������ ������","�������� ������"],"mail_not_found":"������������ �� ������","mail_peer_profile_likes_replies_tooltip":"������ � ������ � ������������ �������� � 2020 ����","mail_recent_searches":"������� �� ������","mail_recording_audio_several":["","���������� �����","���������� �����","���������� �����"],"mail_reject_mr_confirmation_text":"�� ������������� ������ ��������� ����������� �������?","mail_reject_mr_confirmation_title":"��������� �����������","mail_restore":"������������","mail_restored":"��������� �������������","mail_return_to_chat":"��������� � ������","mail_return_to_vkcomgroup":"����������� �� �����","mail_search_conversations_sep":"������","mail_search_creation":"������� ��� ��� �������","mail_search_dialogs_sep":"���� � ����������","mail_search_messages":"���������","mail_search_only_messages":"������ � ������ ����������","mail_search_only_messages_comm":"������ � ���������� ����������","mail_send_message_error":"������ ��� �������� ���������","mail_settings":"���������� � ������","mail_source_info":"�� ��������: {link}<br>{info}","mail_sure_to_delete_all":"�� ������������� ������ <b>������� ��� ���������<\/b> � ������ �������������?<br><br>�������� ��� �������� ����� <b>����������<\/b>.","mail_typing_several":["","��������","��������","��������"],"mail_unfollow_channel":"����������","mail_unfollow_channel_confirmation":"�� ������������� ������ <b>���������� � ������� ��� ���������<\/b> �� ����� ������?","mail_unpin":"��������� ���������","mail_unpin_text":"�� ������������� ������ ��������� ���������? ��� ��������� ������ ��� ��������� ������.","mail_unpin_title":"��������� ���������","mail_unread_message":"��������� �� ���������","mail_vkcomgroup_leave_confirm":"����������� �� ������, �� �� ������ �������� ����� ���������. �� ������� ��������� ������������.<br>","mail_vkcomgroup_settings":"���������� � ������","months_of":{"1":"������","2":"�������","3":"�����","4":"������","5":"���","6":"����","7":"����","8":"�������","9":"��������","10":"�������","11":"������","12":"�������"},"months_sm_of":{"1":"���","2":"���","3":"���","4":"���","5":"���","6":"���","7":"���","8":"���","9":"���","10":"���","11":"���","12":"���"},"text_N_symbols_remain":["","������� %s ����","�������� %s �����","�������� %s ������"],"text_exceeds_symbol_limit":["","���������� ����� �������� �� %s ����.","���������� ����� �������� �� %s �����.","���������� ����� �������� �� %s ������."],"votes_flex":["","�����","������","�������"]});
addTemplates({"_":"_","stickers_sticker_url":"https:\/\/vk.com\/sticker\/1-%id%-%size%"});
window.cur = window.cur || {};
cur['emojiHintsSendLogHash']="ac5ca52fd85e0f2c43";
ge('msg_back_button').onclick = function() {
  history.go(-1);
};
;(function (d, w) {
if (w.__dev) {
  return
}
var ts = d.createElement("script"); ts.type = "text/javascript"; ts.async = true;
ts.src = (d.location.protocol == "https:" ? "https:" : "http:") + "//top-fwz1.mail.ru/js/code.js";
var f = function () {var s = d.getElementsByTagName("script")[0]; s.parentNode.insertBefore(ts, s);};
if (w.opera == "[object Opera]") { d.addEventListener("DOMContentLoaded", f, false); } else { f(); }
})(document, window);;(function (d, w) {
if (w.__dev) {
  return;
}
if(!w._tns){w._tns = {}};
w._tns.tnsPixelSocdem = "13"
w._tns.tnsPixelType = "unauth"
})(document, window);
      window.curReady && window.curReady();
    }
  </script>
</body>

</html>