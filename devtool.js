chrome.devtools.panels.create(
    "CatX.FM",
    "icon.jpg",
    "panel.html",
    function cb(panel) {
        panel.onShown.addListener(function(win){ win.focus(); });
    }
);
