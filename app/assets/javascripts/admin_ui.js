// Admin UI: toast flash messages + clear-filters fallback (vanilla JS)
document.addEventListener("DOMContentLoaded", function () {

  // ── Toast container ───────────────────────────────────────────────────────
  var container = document.createElement("div");
  container.id = "aa-toast-container";
  document.body.appendChild(container);

  var TYPE_MAP = {
    notice:  { icon: "✓", cls: "success" },
    success: { icon: "✓", cls: "success" },
    alert:   { icon: "✗", cls: "error"   },
    error:   { icon: "✗", cls: "error"   },
    warning: { icon: "⚠", cls: "warning" }
  };

  function showToast(message, type) {
    var t = TYPE_MAP[type] || { icon: "ℹ", cls: "notice" };
    var el = document.createElement("div");
    el.className = "aa-toast aa-toast--" + t.cls;
    el.innerHTML =
      '<span class="aa-toast__icon">' + t.icon + "</span>" +
      '<span class="aa-toast__msg">'  + message + "</span>" +
      '<button class="aa-toast__close" aria-label="Dismiss">×</button>';
    container.appendChild(el);

    // Animate in
    requestAnimationFrame(function () {
      requestAnimationFrame(function () { el.classList.add("aa-toast--in"); });
    });

    var timer = setTimeout(function () { dismiss(el); }, 5000);
    el.querySelector(".aa-toast__close").addEventListener("click", function () {
      clearTimeout(timer); dismiss(el);
    });
  }

  function dismiss(el) {
    el.classList.remove("aa-toast--in");
    el.addEventListener("transitionend", function () { el.remove(); }, { once: true });
  }

  // ActiveAdmin renders flashes as: <div class="flashes"><div class="flash flash_notice">msg</div></div>
  document.querySelectorAll(".flashes .flash").forEach(function (el) {
    var type = (el.className.match(/flash_(\w+)/) || [])[1] || "notice";
    showToast(el.textContent.trim(), type);
  });

  // Hide the original flash bar (we replaced it with toasts)
  document.querySelectorAll(".flashes").forEach(function (el) {
    el.style.display = "none";
  });

  // ── Clear Filters fallback ────────────────────────────────────────────────
  document.addEventListener("click", function (e) {
    var btn = e.target.closest(".clear_filters_btn, [data-clear-filters]");
    if (!btn) return;
    e.preventDefault();
    var form = document.querySelector(".filter_form");
    if (form) {
      form.querySelectorAll("input:not([type=hidden]):not([type=submit]), select").forEach(function (i) { i.value = ""; });
      form.querySelectorAll("input[type=checkbox]").forEach(function (i) { i.checked = false; });
      form.submit();
    } else {
      window.location.href = window.location.pathname;
    }
  });

});
