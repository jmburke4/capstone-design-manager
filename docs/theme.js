(function () {
    var themeKey = "site-theme";
    var initialTheme;

    function getSystemPreference() {
        return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
    }

    function getStoredTheme() {
        try {
            var savedTheme = localStorage.getItem(themeKey);
            return savedTheme === "light" || savedTheme === "dark" ? savedTheme : null;
        } catch (error) {
            return null;
        }
    }

    function getCurrentTheme() {
        return getStoredTheme() || getSystemPreference();
    }

    function setToggleLabel(theme) {
        var label = theme === "dark" ? "Switch to light mode" : "Switch to dark mode";
        document.querySelectorAll("[data-theme-toggle]").forEach(function (button) {
            button.setAttribute("aria-label", label);
            button.setAttribute("title", label);
        });
    }

    function applyTheme(theme, persist) {
        document.documentElement.setAttribute("data-theme", theme);
        document.documentElement.style.colorScheme = theme;

        if (persist) {
            try {
                localStorage.setItem(themeKey, theme);
            } catch (error) {
                // Ignore storage failures and continue with the in-memory theme.
            }
        }

        setToggleLabel(theme);
        window.dispatchEvent(new CustomEvent("site-theme-changed", { detail: { theme: theme } }));
    }

    function toggleTheme() {
        var nextTheme = document.documentElement.getAttribute("data-theme") === "dark" ? "light" : "dark";
        applyTheme(nextTheme, true);
    }

    function ensureThemeToggle() {
        document.querySelectorAll("footer").forEach(function (footer) {
            if (footer.querySelector("[data-theme-toggle]")) {
                return;
            }

            var button = document.createElement("button");
            button.type = "button";
            button.className = "theme-toggle";
            button.setAttribute("data-theme-toggle", "true");
            button.innerHTML = '<span class="theme-icon" aria-hidden="true"></span>';
            button.addEventListener("click", toggleTheme);
            footer.appendChild(button);
        });
    }

    function initializeTheme() {
        applyTheme(initialTheme, false);
        ensureThemeToggle();
        setToggleLabel(document.documentElement.getAttribute("data-theme") || "light");

        var media = window.matchMedia("(prefers-color-scheme: dark)");
        var onSystemThemeChange = function () {
            if (!getStoredTheme()) {
                applyTheme(getSystemPreference(), false);
            }
        };

        if (typeof media.addEventListener === "function") {
            media.addEventListener("change", onSystemThemeChange);
        } else if (typeof media.addListener === "function") {
            media.addListener(onSystemThemeChange);
        }
    }

    initialTheme = getCurrentTheme();
    document.documentElement.setAttribute("data-theme", initialTheme);
    document.documentElement.style.colorScheme = initialTheme;

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", initializeTheme);
    } else {
        initializeTheme();
    }
})();
