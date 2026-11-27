// Tiny i18n for the static pages: elements with data-i18n get their text from
// window.PAGE_STRINGS[lang][key] (HTML allowed). Language: ?lang= → saved choice → browser → en.
(function () {
  var LANGS = ["en", "vi", "ja"];

  function pickLanguage() {
    var param = new URLSearchParams(location.search).get("lang");
    if (LANGS.indexOf(param) >= 0) return param;
    try {
      var saved = localStorage.getItem("littlemark.lang");
      if (LANGS.indexOf(saved) >= 0) return saved;
    } catch (e) {}
    var browser = (navigator.language || "en").slice(0, 2);
    return LANGS.indexOf(browser) >= 0 ? browser : "en";
  }

  function apply(lang) {
    var strings = (window.PAGE_STRINGS || {})[lang] || {};
    var shared = (window.SHARED_STRINGS || {})[lang] || {};
    document.documentElement.lang = lang;
    document.querySelectorAll("[data-i18n]").forEach(function (el) {
      // The English text in the HTML is the fallback for keys a language doesn't override
      if (el.dataset.i18nDefault === undefined) el.dataset.i18nDefault = el.innerHTML;
      var key = el.getAttribute("data-i18n");
      el.innerHTML = strings[key] || shared[key] || el.dataset.i18nDefault;
    });
    if (strings["meta.title"]) document.title = strings["meta.title"];
    var select = document.querySelector(".lang");
    if (select) select.value = lang;
  }

  window.SHARED_STRINGS = {
    en: { "nav.privacy": "Privacy", "nav.support": "Support", "footer.rights": "© 2026 Tai Phan Van" },
    vi: { "nav.privacy": "Quyền riêng tư", "nav.support": "Hỗ trợ", "footer.rights": "© 2026 Phan Văn Tài" },
    ja: { "nav.privacy": "プライバシー", "nav.support": "サポート", "footer.rights": "© 2026 Tai Phan Van" }
  };

  document.addEventListener("DOMContentLoaded", function () {
    var lang = pickLanguage();
    apply(lang);
    var select = document.querySelector(".lang");
    if (select) {
      select.addEventListener("change", function () {
        try { localStorage.setItem("littlemark.lang", select.value); } catch (e) {}
        apply(select.value);
      });
    }
  });
})();
