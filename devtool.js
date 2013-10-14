chrome.devtools.panels.create(
    "CatX.FM",
    "radio.png",
    "panel.html",
    function cb(panel) {
        panel.onShown.addListener(function(win){ win.focus(); });
    }
);
