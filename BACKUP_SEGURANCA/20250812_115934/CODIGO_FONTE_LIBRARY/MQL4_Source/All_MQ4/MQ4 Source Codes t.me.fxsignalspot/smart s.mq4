<!DOCTYPE html>
<html  lang="ru">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<link rel="shortcut icon" href="/images/icons/favicons/fav_logo.ico?6" />

<link rel="apple-touch-icon" href="/images/icons/pwa/apple/default.png?8">

<meta http-equiv="content-type" content="text/html; charset=windows-1251" />
<meta name="description" content="ВКонтакте – универсальное средство для общения и поиска друзей и одноклассников, которым ежедневно пользуются десятки миллионов человек. Мы хотим, чтобы друзья, однокурсники, одноклассники, соседи и коллеги всегда оставались в контакте." />


<title>Ошибка | ВКонтакте</title>

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
      var alert = '<div class="OldBrowser__container" style="width:960px;">  Установите <a href="/badbrowser.php?source=old_browser_alert" target="_blank">один из этих браузеров</a>, чтобы работа ВКонтакте была быстрой и стабильной.  <span class="OldBrowser__close" aria-label="Закрыть"  role="button" onclick="hideOldBrowser();"></span></div>';
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
  <div class="head_nav_item fl_l"><a class="top_home_link fl_l CovidLogo" href="/" aria-label="На главную" accesskey="1"  onmouseover="this.className.indexOf(&#39;bugtracker_logo&#39;) === -1 &amp;&amp; bodyNode.className.indexOf(&#39;WideScreenAppPage&#39;) === -1 &amp;&amp; showTooltip(this,
{
  text: &quot;&lt;div class=\&quot;CovidTooltip__logo\&quot;&gt;&lt;\/div&gt;&lt;div class=\&quot;CovidTooltip__title\&quot;&gt;Оставайтесь дома&lt;\/div&gt;&lt;div class=\&quot;CovidTooltip__text\&quot;&gt;Мойте руки, избегайте скопления людей, по возможности не выходите из дома и проводите &lt;a href=\&quot;\/feed?section=stayhome\&quot; onclick=\&quot;return typeof window.statlogsValueEvent !== &amp;#39;undefined&amp;#39; &amp;amp;&amp;amp; window.statlogsValueEvent(&amp;#39;coronavirus_tooltip_click&amp;#39;, 1) || nav.go(this, event)\&quot;&gt;время с пользой&lt;\/a&gt;.&lt;\/div&gt;&quot;,
  className: &#39;CovidTooltip&#39;,
  width: 356,
  dir: &#39;top&#39;,
  shift: [0, 0, 6],
  hidedt: 60, showdt: 600,
  hasover: true,
  onShowStart: function() {window.statlogsValueEvent !== &#39;undefined&#39; &amp;&amp; window.statlogsValueEvent(&#39;coronavirus_tooltip_show&#39;, 1)}
})"><div class="top_home_logo"></div><div class="CovidLogo__hashtag ">#лучшедома</div></a></div>
  <div class="head_nav_item fl_l"><div id="ts_wrap" class="ts_wrap" onmouseover="TopSearch.initFriendsList();">
  <input name="disable-autofill" style="display: none;" />
  <input type="text" onmousedown="event.cancelBubble = true;" ontouchstart="event.cancelBubble = true;" class="text ts_input" id="ts_input" autocomplete="off" name="disable-autofill" placeholder="Поиск" aria-label="Поиск" />
</div></div>
  <div class="head_nav_item fl_l head_nav_btns"><div id="top_audio_layer_place" class="top_audio_layer_place"></div></div>
  <div class="head_nav_item fl_r"><a class="top_nav_link" href="" id="top_switch_lang" style="display: none;" onclick="ajax.post('al_index.php', {act: 'change_lang', lang_id: 3, hash: 'cc4b288242047722c1' }); return false;">
  Switch to English
</a><a class="top_nav_link" href="/join" id="top_reg_link" style="" onclick="return !showBox('join.php', {act: 'box', from: nav.strLoc}, {}, event)">
  регистрация
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
    <div class="label">Телефон или email</div>
    <div class="labeled"><input type="text" name="email" class="dark" id="quick_email" /></div>
    <div class="label">Пароль</div>
    <div class="labeled"><input type="password" name="pass" class="dark" id="quick_pass" onkeyup="toggle('quick_expire', !!this.value);toggle('quick_forgot', !this.value)" /></div>
    <input type="submit" class="submit" />
  </form>
  <button class="quick_login_button flat_button button_wide" id="quick_login_button">Войти</button>
  <button class="quick_reg_button flat_button button_wide" id="quick_reg_button" style="" onclick="top.showBox('join.php', {act: 'box', from: nav.strLoc})">Регистрация</button>
  <div class="clear forgot"><div class="checkbox" id="quick_expire" onclick="checkbox(this);ge('quick_expire_input').value=isChecked(this)?1:'';">Чужой компьютер</div><a id="quick_forgot" class="quick_forgot" href="/restore" target="_top">Забыли пароль?</a></div>
</div>
      </div>
    </div>

    <div id="page_body" class="fl_r " style="width: 795px;">
      
      <div id="wrap_between"></div>
      <div id="wrap3"><div id="wrap2">
  <div id="wrap1">
    <div id="content"><div class="message_page page_block">
  <div class="message_page_title">Ошибка</div>
  <div class="message_page_body">
    Пользователь, который разместил документ, заблокирован.
    <button class="flat_button message_page_btn" id="msg_back_button">Назад</button>
  </div>
</div></div>
  </div>
</div></div>
    </div>

    <div id="footer_wrap" class="footer_wrap fl_r" style="width: 960px;"><div class="footer_nav" id="bottom_nav">
  <div class="footer_copy"><a href="/about">ВКонтакте</a> &copy; 2006–2020</div>
  <div class="footer_links">
    <a class="bnav_a" href="/about">О ВКонтакте</a>
    <a class="bnav_a" href="/support?act=home" style="display: none;">Помощь</a>
    <a class="bnav_a" href="/terms">Правила</a>
    <a class="bnav_a" href="/ads" style="">Реклама</a>
    
    <a class="bnav_a" href="/dev">Разработчикам</a>
    <a class="bnav_a" href="/jobs" style="display: none;">Вакансии</a>
  </div>
  <div class="footer_lang"><a class="footer_lang_link" onclick="ajax.post('al_index.php', {act: 'change_lang', lang_id: 0, hash: 'cc4b288242047722c1'})">Русский</a><a class="footer_lang_link" onclick="ajax.post('al_index.php', {act: 'change_lang', lang_id: 1, hash: 'cc4b288242047722c1'})">Українська</a><a class="footer_lang_link" onclick="ajax.post('al_index.php', {act: 'change_lang', lang_id: 3, hash: 'cc4b288242047722c1'})">English</a><a class="footer_lang_link" onclick="if (vk.al) { showBox('lang.php', {act: 'lang_dialog', all: 1}, {params: {dark: true, bodyStyle: 'padding: 0px'}, noreload: true}); } else { changeLang(1); } return false;">все языки &raquo;</a></div>
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
  showFastBox('Предупреждениe', 'Не удаётся пройти авторизацию по защищённому соединению. Чаще всего это происходит, когда на Вашем компьютере установлены неправильные текущие дата и время. Пожалуйста, проверьте настройки даты и времени в системе и перезапустите браузер.');
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
addLangKeys({"global_apps":"Приложения","global_friends":"Друзья","global_communities":"Сообщества","head_search_results":"Результаты поиска","global_chats":"Диалоги","global_show_all_results":"Показать все результаты","global_news_search_results":"Результаты поиска в новостях","global_emoji_cat_recent":"Часто используемые","global_emoji_cat_1":"Эмоции","global_emoji_cat_2":"Животные и растения","global_emoji_cat_3":"Жесты и люди","global_emoji_cat_4":"Еда и напитки","global_emoji_cat_5":"Спорт и активности","global_emoji_cat_6":"Путешествия и транспорт","global_emoji_cat_7":"Предметы","global_emoji_cat_8":"Символы","global_emoji_cat_9":"Флаги","stories_archive_privacy_info":"Истории в архиве видите только Вы","stories_remove_warning":"Вы действительно хотите удалить историю?<br>Отменить действие будет невозможно.","stories_remove_from_narrative_warning":"Вы действительно хотите удалить историю? <br>Она так же удалится из сюжета.","stories_narrative_remove_warning":"Вы действительно хотите удалить сюжет?<br>Отменить действие будет невозможно.","stories_remove_confirm":"Удалить","stories_answer_placeholder":"Ваше сообщение…","stories_answer_sent":"Сообщение отправлено","stories_blacklist_title":"Скрыты из историй","stories_settings":"Настройки","stories_add_blacklist_title":"Скрытие из историй","stories_add_blacklist_message":"Пользователь останется в друзьях, но истории не будут показываться в новостях.","stories_add_blacklist_button":"Скрыть из историй","stories_add_blacklist_message_group":"Вы останетесь подписчиком сообщества, но истории не будут показываться в новостях.","stories_remove_from_blacklist_button":"Вернуть в истории","stories_error_cant_load":"Не удалось загрузить историю.","stories_try_again":"Попробовать ещё раз","stories_error_expired":"Историю можно было посмотреть<br>в течение 24 часов после публикации","stories_error_deleted":"История удалена","stories_error_private":"Автор скрыл историю","stories_error_one_time_seen":"История больше не доступна","stories_mask_tooltip":"Попробовать эту маску","stories_mask_sent":"Маска отправлена на телефон","stories_followed":"Вы подписались&#33;","stories_unfollowed":"Вы отписались","stories_is_ad":"Реклама","stories_private_story":"Приватная<br>история","stories_expired_story":"История<br>истекла","stories_deleted_story":"История<br>удалена","stories_bad_browser":"Истории не поддерживаются в Вашем браузере","stories_delete_all_replies_confirm":"Вы действительно хотите удалить все ответы {name} за последние сутки? <br>Отменить действие будет невозможно.","stories_hide_reply_button":"Скрыть ответ","stories_reply_hidden":"Ответ на историю скрыт.","stories_restore":"Восстановить","stories_hide_reply_continue":"Продолжить просмотр","stories_hide_all_replies":["","Скрыть все его ответы за последние сутки","Скрыть все её ответы за последние сутки"],"stories_reply_add_to_blacklist":"Занести в чёрный список","stories_hide_reply_warning":"Вы действительно хотите скрыть этот ответ?<br>Отменить действие будет невозможно.","stories_replies_more_button":["","Показать ещё %s ответившего","Показать ещё %s ответивших","Показать ещё %s ответивших"],"stories_all_replies_hidden":"Все ответы скрыты","stories_ban_confirm":"Вы действительно хотите добавить в чёрный список {name}?<br>Отменить действие будет невозможно.","stories_banned":"Пользователь в чёрном списке","stories_share":"Поделиться","stories_like":"Нравится","stories_follow":"Подписаться","stories_unfollow":"Отписаться","stories_report":"Пожаловаться","stories_report_sent":"Жалоба отправлена","stories_narrative_show":"Посмотреть cюжет","stories_narrative_bookmark_added":"Сюжет сохранён в {link}закладках{\/link}","stories_narrative_bookmark_deleted":"Сюжет удалён из закладок","stories_narrative_edit_button":"Редактировать сюжет","stories_narrative_add_bookmark_button":"Сохранить в закладках","stories_narrative_remove_bookmark_button":"Удалить из закладок","stories_narrative_copy_link":"Скопировать ссылку","stories_narrative_copy_link_done":"Ссылка скопирована","stories_show_hashtag_link":"Поиск по хештегу","stories_go_to_place":"Перейти к месту","stories_go_to_group":"Открыть сообщество","stories_go_to_profile":"Открыть профиль","stories_go_to_post":"Перейти к записи","stories_go_to_story":"Перейти к истории","stories_share_question":"Поделиться мнением","stories_live_ended_title":"Спасибо за просмотр&#33;","stories_live_ended_desc_club":"Сообщество {name} <br>завершило трансляцию.","stories_live_ended_desc_user":["","{name} завершил трансляцию.","{name} завершила трансляцию."],"stories_live_ended_open_club":"Открыть сообщество","stories_live_ended_open_user":"Открыть профиль","stories_live_ended_watch_next":"Смотреть далее","stories_live_N_watching":["","%s смотрит сейчас","%s смотрят сейчас","%s смотрят сейчас"],"stories_live_chat_msg_too_long":"Сообщение слишком длинное ","stories_questions_title":"Мнения","stories_question_reply":"Ответить","stories_question_reply_error":"Вы не можете отправить сообщение этому пользователю, так как он ограничил круг лиц, которые могут присылать ему сообщения.","stories_question_reply_send":"Отправить","stories_question_reply_placeholder":"Напишите сообщение...","stories_question_delete":"Удалить мнение","stories_question_author_ban":"Заблокировать","stories_question_author_unban":"Разблокировать автора","stories_question_author_blocked":"Автор заблокирован","stories_question_author_unblocked":"Автор разблокирован","stories_question_author_report":"Пожаловаться","stories_question_report_title":"Жалоба на мнение","stories_question_report_send":"Отправить","stories_question_more":"Действия","stories_question_sent":"Вы поделились мнением с {name}","stories_question_reply_box_title":"Сообщение {name}","stories_question_ask_placeholder":"Введите текст...","stories_question_ask_box_title":"Мнение к истории {name}","stories_question_report_reason":"Укажите причину","stories_question_forbidden":"Вы не можете поделиться мнением","stories_audio_add":"Добавить в мою музыку","stories_audio_added":"Аудиозапись добавлена","stories_audio_delete":"Удалить аудиозапись","stories_audio_deleted":"Аудиозапись удалена","stories_audio_next_audio":"Слушать далее","stories_reactions_title":"Быстрые реакции","stories_reactions_tooltip_feature":"Нажмите на поле ввода, чтобы отправить реакцию","stories_go_to_market_item":"Подробнее","stories_market_access_error_title":"Ошибка","stories_market_access_error_text":"Данный товар недоступен","stories_groups_feed_block":"Сообщества","stories_settings_box_tab_all":"Все","stories_settings_box_tab_separately":"Отображаемые отдельно","stories_settings_box_tab_grouped":"Сгруппированные","stories_settings_box_search_placeholder":"Поиск по сообществам","stories_settings_box_put_back":"Отображать последним","stories_groups_grid_title":"Истории сообществ","stories_go_to_app":"Перейти к приложению","stories_groups_grid_text":"Здесь собраны истории сообществ, на которые Вы подписаны","stories_groups_tooltip":"Отмечайте истории, которые хотите видеть в общем списке","stories_settings_saved":"Настройки сохранены","stories_detailed_stats":"Подробная статистика","stories_privacy_feedback_hint":"У Вас ограничен доступ к историям. Перейдите в настройки приватности, чтобы это изменить.","stories_privacy_empty_views_hint":"Истории видите только Вы. Сделайте их доступными всем, чтобы получать больше просмотров","stories_go_to_settings":"Перейти в настройки","stories_stat_counter_off":"выкл","stories_question_select_public":"Публично","stories_question_select_author_only":"Видно только автору","stories_question_select_anonymous":"Анонимно","stories_question_about_user_tooltip":"<b>Публично<\/b><br>{name} сможет указать Ваше имя при публикации мнения.<br><br><b>Имя видно автору<\/b><br>{name} увидит Ваше имя, но не сможет указать его при публикации мнения.<br><br><b>Анонимно<\/b><br>{name} не увидит Ваше имя и не сможет указать его при публикации мнения.","stories_question_about_group_tooltip":"<b>Публично<\/b><br>Руководитель сообщества сможет указать Ваше имя при публикации мнения.<br><br><b>Имя видно автору<\/b><br>Руководитель сообщества увидит Ваше имя, но не сможет указать его при публикации мнения.<br><br><b>Анонимно<\/b><br>Руководитель сообщества не увидит Ваше имя и не сможет указать его при публикации мнения.","stories_question_about_user_tooltip_without_anon":"<b>Публично<\/b><br>{name} сможет указать Ваше имя при публикации мнения.<br><br><b>Имя видно автору<\/b><br>{name} увидит Ваше имя, но не сможет указать его при публикации мнения.","stories_question_about_group_tooltip_without_anon":"<b>Публично<\/b><br>Руководитель сообщества сможет указать Ваше имя при публикации мнения.<br><br><b>Имя видно автору<\/b><br>Руководитель сообщества увидит Ваше имя, но не сможет указать его при публикации мнения.","stories_voting_show_result":"Посмотреть результаты"}, true);
addLangKeys({"box_close":"Закрыть","calls_add_participants":"Добавить участников","calls_add_participants_to_call":"Добавить в звонок участников беседы","calls_busy":"Занято","calls_busy_error":"Пользователь уже разговаривает. Перезвоните позже.","calls_call_to_chat_members":"Позвонить участникам беседы","calls_callee_is_offline":"Не в сети","calls_chat_busy_error":"Вы не можете начать звонок в этой беседе, потому что в ней уже идёт звонок.","calls_error_no_cam":"Необходим доступ к камере.","calls_error_no_cam_and_mic":"Необходим доступ к камере и микрофону.","calls_error_no_mic":"Необходим доступ к микрофону.","calls_flood_error":"Вы слишком часто звоните. Повторите попытку позже.","calls_hangup_description":"Вы уверены, что хотите завершить звонок?","calls_incoming_audiocall":"Входящий аудиозвонок","calls_incoming_process_error":"Вам позвонили, но принять звонок в версии для компьютера не получится из-за ошибки.<br>Попробуйте принять вызов в мобильном приложении. Если это не поможет, обновите страницу и попросите собеседника перезвонить.","calls_incoming_videocall":"Входящий видеозвонок","calls_no_camera":"Камера не обнаружена","calls_privacy_error":"Звонок не удался, так как у Вас или собеседника звонки запрещены в настройках приватности.","calls_reject":"Отклонить","calls_reject_call":"Отклонить звонок","calls_reject_description":"Вы уверены, что хотите отклонить звонок?","calls_reject_title":"Отклонить звонок","calls_rejected_status":"Вызов отклонён","calls_reply":"Ответить","calls_reply_with_audio":"Ответить с аудио","calls_reply_with_video":"Ответить с видео","calls_selected":"Выбрано {selected} из {limit}","calls_settings":"Настройки","calls_settings_camera":"Камера","calls_settings_mic":"Микрофон","calls_settings_no_camera":"Камера не обнаружена","calls_settings_no_mic":"Микрофон не обнаружен","calls_start_error":"Во время звонка произошла ошибка. Повторите попытку позже.","calls_status_connecting":"Подключение","calls_status_hangup":"Отключение","calls_status_no_permissions":"Нет разрешений","calls_status_waiting":"Ожидание","calls_unsupported_browser_error":"Звонок не удался, потому что Ваш браузер устарел. Обновите его, чтобы пользоваться звонками.","captcha_cancel":"Отмена","captcha_enter_code":"Введите код с картинки","captcha_send":"Отправить","global_add":"Добавить","global_age_days":["","%s день","%s дня","%s дней"],"global_age_months":["","%s месяц","%s месяца","%s месяцев"],"global_age_seconds":["","%s секунда","%s секунды","%s секунд"],"global_age_weeks":["","%s неделя","%s недели","%s недель"],"global_age_years":["","%s год","%s года","%s лет"],"global_and":"{before} и {after}","global_apps":"Приложения","global_back":"Назад","global_box_title_back":"Вернуться назад","global_cancel":"Отмена","global_captcha_input_here":"Введите код","global_chats":"Диалоги","global_close":"Закрыть","global_communities":"Сообщества","global_date":["","{day} {month} {year}","вчера","сегодня","завтра"],"global_days_accusative":["","%s день","%s дня","%s дней"],"global_delete":"Удалить","global_error":"Ошибка","global_friends":"Друзья","global_hours":["","%s час","%s часа","%s часов"],"global_hours_accusative":["","%s час","%s часа","%s часов"],"global_hours_ago":["","%s час назад","%s часа назад","%s часов назад"],"global_just_now":"только что","global_mins_ago":["","%s минуту назад","%s минуты назад","%s минут назад"],"global_minutes":["","%s минута","%s минуты","%s минут"],"global_minutes_accusative":["","%s минуту","%s минуты","%s минут"],"global_money_amount_rub":["","%s рубль","%s рубля","%s рублей"],"global_months_accusative":["","%s месяц","%s месяца","%s месяцев"],"global_news_search_results":"Результаты поиска в новостях","global_no":"Нет","global_online_long_ago":["","заходил давно","заходила давно"],"global_online_this_month":["","заходил в этом месяце","заходил в этом месяце"],"global_online_was_recently":["","заходил недавно","заходила недавно"],"global_online_was_week":["","заходил на этой неделе","заходила на этой неделе"],"global_recaptcha_title":"Подтверждение действия","global_save":"Сохранить","global_seconds_accusative":["","%s секунду","%s секунды","%s секунд"],"global_secs_ago":["","%s секунду назад","%s секунды назад","%s секунд назад"],"global_short_date":["","{day} {month}","вчера","сегодня","завтра"],"global_short_date_time":["","{day} {month} в {hour}:{minute}","вчера в {hour}:{minute}","сегодня в {hour}:{minute}","завтра в {hour}:{minute}"],"global_short_date_time_l":["","{day} {month} в {hour}:{minute}","вчера в {hour}:{minute}","сегодня в {hour}:{minute}","завтра в {hour}:{minute}"],"global_show_all_results":"Показать все результаты","global_sorry_error":"К сожалению, произошла ошибка","global_to_top":"Наверх","global_user_is_online":"онлайн","global_user_is_online_mobile":"онлайн с телефона","global_warning":"Предупреждениe","global_weeks_accusative":["","%s неделю","%s недели","%s недель"],"global_word_hours_ago":["","час назад","два часа назад","три часа назад","четыре часа назад","пять часов назад"],"global_word_mins_ago":["","минуту назад","две минуты назад","три минуты назад","4 минуты назад","5 минут назад"],"global_word_secs_ago":["","только что","две секунды назад","три секунды назад","четыре секунды назад","пять секунд назад"],"global_years_accusative":["","%s год","%s года","%s лет"],"global_yes":"Да","head_search_results":"Результаты поиска","mail_ad_tag_no_access_box_text":"Недостаточно прав в рекламном кабинете, чтобы просматривать объявление.","mail_ad_tag_no_access_box_title":"Ошибка","mail_ad_tag_no_access_text":"Из рекламы","mail_ad_tag_text_prefix":"AD","mail_added_article":"Статья","mail_added_artist":"Музыкант","mail_added_audio":"Аудиозапись","mail_added_audio_album":"Альбом","mail_added_audio_playlist":"Плейлист","mail_added_audiomsg":"Голосовое сообщение","mail_added_audios":["","Аудиозапись","%s аудиозаписи","%s аудиозаписей"],"mail_added_call":"Звонок","mail_added_clips":"Клипы","mail_added_doc":"Документ","mail_added_docs":"Документ","mail_added_geo":"Карта","mail_added_gift":"Подарок","mail_added_graffiti":"Граффити","mail_added_group":"Группа","mail_added_link":"Ссылка","mail_added_market_item":"Товар","mail_added_mask":"Маска","mail_added_money_request":"Запрос на денежный перевод","mail_added_money_transfer":"Денежный перевод","mail_added_msg":"Cообщение","mail_added_msgs":"Cообщения","mail_added_photo":"Фотография","mail_added_photos":["","Фотография","%s фотографии","%s фотографий"],"mail_added_podcast":"Подкаст","mail_added_poll":"Опрос","mail_added_sticker":"Стикер","mail_added_story":"История","mail_added_video":"Видеозапись","mail_added_videos":["","Видеозапись","%s видеозаписи","%s видеозаписей"],"mail_added_vkpay":"Запрос VK Pay","mail_added_wall":"Запись на стене","mail_added_wall_reply":"Комментарий на стене","mail_allow_comm_messages":"Разрешить сообщения","mail_and_peer":"и ещё {count} {typing}","mail_and_peer_one":"и","mail_block_comm_messages":"Запретить сообщения","mail_block_notify_messages":"Запретить оповещения","mail_block_user":"Заблокировать пользователя","mail_by_you":"Вы","mail_call_canceled":"Вы отменили звонок","mail_call_declined":"Звонок отклонён","mail_call_declined_by":["","{user_name} отклонил звонок","{user_name} отклонила звонок"],"mail_call_incoming":"Входящий звонок ({duration})","mail_call_missed":"Вы пропустили звонок","mail_call_outgoing":"Исходящий звонок ({duration})","mail_call_snippet_canceled":"Отменён","mail_call_snippet_declined":"Отклонён","mail_call_snippet_incoming":"Входящий звонок","mail_call_snippet_incoming_video":"Входящий видеозвонок","mail_call_snippet_missed":"Пропущен","mail_call_snippet_missed_call":"Пропущенный звонок","mail_call_snippet_outgoing":"Исходящий звонок","mail_call_snippet_outgoing_video":"Исходящий видеозвонок","mail_chat_leave_confirm":"Покинув беседу, Вы не будете получать новые сообщения от участников. Вы сможете вернуться при наличии свободных мест.<br>","mail_chat_sure_to_delete_all":"Вы действительно хотите <b>удалить всю переписку<\/b> в этой беседе?<br><br>Отменить это действие будет <b>невозможно<\/b>.","mail_clear_recent":"Очистить","mail_create_chat_remove_user":"Удалить собеседника","mail_delete":"Удалить","mail_delete_for_all":"Удалить для всех","mail_deleteall1":"Удалить все сообщения","mail_deleted_stop":"Сообщение удалено.","mail_dialog_msg_delete_N":["","Вы действительно хотите <b>удалить<\/b> сообщение?","Вы действительно хотите <b>удалить<\/b> %s сообщения?","Вы действительно хотите <b>удалить<\/b> %s сообщений?"],"mail_dialog_msg_delete_title":"Удалить сообщение","mail_error":"Ошибка","mail_expired_message":"Сообщение исчезло","mail_fwd_msgs":["","%s сообщение","%s сообщения","%s сообщений"],"mail_gift_message_sent":["","отправил подарок","отправила подарок"],"mail_group_sure_to_delete_all":"Вы действительно хотите <b>удалить всю переписку<\/b> с этим сообществом?<br><br>Отменить это действие будет <b>невозможно<\/b>.","mail_header_online_status":"online","mail_hide_unpin_hover":"Скрыть","mail_im_call_audio":"Аудиозвонок","mail_im_call_video":"Видеозвонок","mail_im_chat_created":["","{from} создал беседу {title}","{from} создала беседу {title}"],"mail_im_chat_own_screenshot":"Вы сделали скриншот беседы","mail_im_chat_screenshot":["","{from} сделал скриншот беседы","{from} сделала скриншот беседы"],"mail_im_create_chat_with":"Добавить собеседников","mail_im_delete_all_history":"Очистить историю сообщений","mail_im_delete_email_contact":"Удалить переписку","mail_im_goto_conversation":"Перейти к диалогу","mail_im_group_call_started":["","{from} начал групповой звонок","{from} начала групповой звонок"],"mail_im_invite_by_link":["","{from} присоединился к беседе по ссылке","{from} присоединилась к беседе по ссылке"],"mail_im_invited":["","{from} пригласил {user}","{from} пригласила {user}"],"mail_im_kicked_from_chat":["","{from} исключил {user}","{from} исключила {user}"],"mail_im_left":["","{from} вышел из беседы","{from} вышла из беседы"],"mail_im_mention_all":"Все участники беседы","mail_im_mention_online":"Все, кто сейчас онлайн","mail_im_mute":"Отключить уведомления","mail_im_n_chat_members":["","%s участник","%s участника","%s участников"],"mail_im_new_messages":["","%s новое сообщение","%s новых сообщения","%s новых сообщений"],"mail_im_peer_profile_delete_note_success":"Комментарий удалён","mail_im_peer_profile_extra_tags":["","%s метка","%s метки","%s меток"],"mail_im_peer_profile_info_empty":"Нет данных","mail_im_peer_profile_info_label_text":"Информация:","mail_im_peer_profile_join_date_empty_text":["","Не подписан","Не подписана"],"mail_im_peer_profile_join_date_label_text":"Дата подписки:","mail_im_peer_profile_manage_tags":"Управление метками","mail_im_peer_profile_manage_tags_add_link":"Добавить метку","mail_im_peer_profile_manage_tags_box_title":"Управление","mail_im_peer_profile_manage_tags_placeholder":"Новая метка","mail_im_peer_profile_manage_tags_remove":"Удалить метку","mail_im_peer_profile_manage_tags_success":"Метки сохранены","mail_im_peer_profile_note_add_link":"Добавить комментарий","mail_im_peer_profile_note_box_placeholder":"Введите текст…","mail_im_peer_profile_note_box_title":"Комментарий администратора","mail_im_peer_profile_note_delete_confirmation_text":"Вы уверены, что хотите удалить комментарий?","mail_im_peer_profile_note_delete_link":"Удалить комментарий","mail_im_peer_profile_note_edit_link":"Редактировать","mail_im_peer_profile_note_label_text":"Комментарий:","mail_im_peer_profile_save_note_success":"Комментарий сохранён","mail_im_peer_profile_tags_empty":"Без меток","mail_im_peer_profile_tags_label_text":"Метки:","mail_im_peer_profile_toggle_tags_off":"Скрыть доступные метки","mail_im_peer_profile_toggle_tags_on":"Показать доступные метки","mail_im_peer_search":"Поиск по истории сообщений","mail_im_photo_removed":["","{from} удалил фотографию беседы","{from} удалила фотографию беседы"],"mail_im_photo_removed_channel":["","{from} удалил фотографию канала","{from} удалила фотографию канала"],"mail_im_photo_set":["","{from} обновил фотографию беседы","{from} обновила фотографию беседы"],"mail_im_pin_message":["","{from} закрепил сообщение «{msg}»","{from} закрепила сообщение «{msg}»"],"mail_im_pin_message_empty2":["","{from} закрепил {link}сообщение{\/link}","{from} закрепила {link}сообщение{\/link}"],"mail_im_returned_to_chat":["","{from} вернулся в беседу","{from} вернулась в беседу"],"mail_im_search_empty":"Не найдено сообщений по такому запросу.","mail_im_show_media_history":"Показать вложения","mail_im_show_media_history_group":"Показать вложения","mail_im_title_updated_channel":["","{from} изменил название канала: {title}","{from} изменила название канала: {title}"],"mail_im_title_updated_dot":["","{from} изменил название беседы: {title}","{from} изменила название беседы: {title}"],"mail_im_unmute":"Включить уведомления","mail_im_unpin_message":["","{from} открепил сообщение «{msg}»","{from} открепила сообщение «{msg}»"],"mail_im_unpin_message_empty2":["","{from} открепил {link}сообщение{\/link}","{from} открепила {link}сообщение{\/link}"],"mail_invitation_sended_ago":"Приглашение отправлено {when}","mail_join_invite_error_title":"Ошибка вступления в чат","mail_keyboard_label_location":"Отправить своё местоположение","mail_keyboard_label_vkpay":"Оплатить через VK Pay","mail_last_activity_tip":["","{user} был в сети {time}","{user} была в сети {time}"],"mail_leave_channel":"Отписаться от канала","mail_leave_chat":"Выйти из беседы","mail_marked_as_spam":"Сообщение помечено как спам и удалено.","mail_menu_pin_hide":"Скрыть закрепл. сообщение","mail_menu_pin_show":"Показать закрепл. сообщение","mail_menu_unpin":"Открепить сообщение","mail_message_edited":"изменено","mail_message_request_reject":"Отклонить","mail_message_wait_until_uploaded":"Пожалуйста, дождитесь окончания загрузки файлов.","mail_messages_expired":["","{count} сообщение исчезло","{count} сообщения исчезло","{count} сообщений исчезло"],"mail_money_amount_rub":["","%s руб.","%s руб.","%s руб."],"mail_money_request_collected_amount":"Собрано {amount}","mail_money_request_collected_amount_from":"Собрано {amount} из {total_amount}","mail_money_request_held_amount":"({amount} ожидает получения)","mail_money_request_message_sent":["","отправил запрос на перевод","отправила запрос на перевод"],"mail_money_tranfer_message_sent":["","перевёл деньги","перевела деньги"],"mail_not_found":"Пользователь не найден","mail_peer_profile_likes_replies_tooltip":"Данные о лайках и комментариях показаны с 2020 года","mail_recent_searches":"Недавно Вы искали","mail_recording_audio_several":["","записывает аудио","записывают аудио","записывают аудио"],"mail_reject_mr_confirmation_text":"Вы действительно хотите отклонить приглашение в беседу?","mail_reject_mr_confirmation_title":"Отклонить приглашение","mail_restore":"Восстановить","mail_restored":"Сообщение восстановлено","mail_return_to_chat":"Вернуться в беседу","mail_return_to_vkcomgroup":"Подписаться на канал","mail_search_conversations_sep":"Беседы","mail_search_creation":"Введите имя или фамилию","mail_search_dialogs_sep":"Люди и сообщества","mail_search_messages":"Сообщения","mail_search_only_messages":"Искать в личных сообщениях","mail_search_only_messages_comm":"Искать в сообщениях сообщества","mail_send_message_error":"Ошибка при отправке сообщения","mail_settings":"Информация о беседе","mail_source_info":"Со страницы: {link}<br>{info}","mail_sure_to_delete_all":"Вы действительно хотите <b>удалить всю переписку<\/b> с данным пользователем?<br><br>Отменить это действие будет <b>невозможно<\/b>.","mail_typing_several":["","печатает","печатают","печатают"],"mail_unfollow_channel":"Отписаться","mail_unfollow_channel_confirmation":"Вы действительно хотите <b>отписаться и удалить все сообщения<\/b> от этого канала?","mail_unpin":"Открепить сообщение","mail_unpin_text":"Вы действительно хотите открепить сообщение? Это изменение увидят все участники беседы.","mail_unpin_title":"Открепить сообщение","mail_unread_message":"Сообщение не прочитано","mail_vkcomgroup_leave_confirm":"Отписавшись от канала, Вы не будете получать новые сообщения. Вы сможете вернуться впоследствии.<br>","mail_vkcomgroup_settings":"Информация о канале","months_of":{"1":"января","2":"февраля","3":"марта","4":"апреля","5":"мая","6":"июня","7":"июля","8":"августа","9":"сентября","10":"октября","11":"ноября","12":"декабря"},"months_sm_of":{"1":"янв","2":"фев","3":"мар","4":"апр","5":"мая","6":"июн","7":"июл","8":"авг","9":"сен","10":"окт","11":"ноя","12":"дек"},"text_N_symbols_remain":["","Остался %s знак","Осталось %s знака","Осталось %s знаков"],"text_exceeds_symbol_limit":["","Допустимый объём превышен на %s знак.","Допустимый объём превышен на %s знака.","Допустимый объём превышен на %s знаков."],"votes_flex":["","голос","голоса","голосов"]});
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