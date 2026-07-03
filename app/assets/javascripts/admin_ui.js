// Admin UI: toast flash messages + clear-filters fallback (vanilla JS, no jQuery needed)
document.addEventListener("DOMContentLoaded", function () {

  // ── Toast flash messages ──────────────────────────────────────────────────
  var toastContainer = document.getElementById("aa-toast-container");
  if (!toastContainer) {
    toastContainer = document.createElement("div");
    toastContainer.id = "aa-toast-container";
    document.body.appendChild(toastContainer);
  }

  var FLASH_ICONS = {
    notice:  "✓",
    success: "✓",
    alert:   "✗",
    error:   "✗",
    warning: "⚠"
  };

  function showToast(message, type) {
    var toast = document.createElement("div");
    toast.className = "aa-toast aa-toast--" + (type || "notice");
    toast.innerHTML =
      '<span class="aa-toast__icon">' + (FLASH_ICONS[type] || "ℹ") + "</span>" +
      '<span class="aa-toast__msg">' + message + "</span>" +
      '<button class="aa-toast__close" aria-label="close">×</button>';

    toastContainer.appendChild(toast);

    // Trigger enter animation
    setTimeout(function () { toast.classList.add("aa-toast--visible"); }, 10);

    // Auto-dismiss after 4 s
    var timer = setTimeout(function () { dismiss(toast); }, 4000);

    toast.querySelector(".aa-toast__close").addEventListener("click", function () {
      clearTimeout(timer);
      dismiss(toast);
    });
  }

  function dismiss(toast) {
    toast.classList.remove("aa-toast--visible");
    toast.addEventListener("transitionend", function () { toast.remove(); }, { once: true });
  }

  // Promote existing ActiveAdmin flash divs into toasts
  document.querySelectorAll("#flash .flash").forEach(function (el) {
    var type = (el.className.match(/flash_(\w+)/) || [])[1] || "notice";
    showToast(el.textContent.trim(), type);
    el.closest("#flash") && (el.closest("#flash").style.display = "none");
  });

  // ── Clear Filters fallback (works without jQuery) ─────────────────────────
  // If the ActiveAdmin clear-filters link was rendered as a plain <a>, clicking
  // it navigates to the resource index — that already works.
  // This handler ensures any button/link with data-clear-filters triggers it.
  document.addEventListener("click", function (e) {
    var btn = e.target.closest("[data-clear-filters], .clear_filters_btn");
    if (!btn) return;
    e.preventDefault();
    var form = document.querySelector("form.filter_form, #filters_sidebar_section form");
    if (form) {
      // Clear all filter inputs then submit
      form.querySelectorAll("input:not([type=hidden]):not([type=submit]), select").forEach(function (el) {
        el.value = "";
      });
      form.querySelectorAll("input[type=checkbox]").forEach(function (el) {
        el.checked = false;
      });
      form.submit();
    } else {
      // Fallback: navigate to current path without query string
      window.location.href = window.location.pathname;
    }
  });

});
