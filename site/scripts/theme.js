/** @private */
const LIGHT = "light"
/** @private */
const DARK = "dark"

/** @private */
function updateTheme(newTheme) {
    localStorage.setItem("theme", newTheme);
    document.documentElement.setAttribute("data-theme", newTheme)
}

/** @private */
function getTheme() {
    const localStorageTheme = localStorage.getItem("theme");
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)");

    if (localStorageTheme) {
        return localStorageTheme
    } else if (prefersDark) {
        return DARK
    } else {
        return LIGHT
    }
}

function toggleTheme() {
    updateTheme(getTheme() === DARK ? LIGHT : DARK)
}


updateTheme(getTheme())
