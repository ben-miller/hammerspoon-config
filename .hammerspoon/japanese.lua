-- Translate term in gTranslate
hs.hotkey.bind(hypo, "T", function()
    local term = formattedSearchTermFromClipboard()
    local url = string.format("https://translate.google.com/?sl=ja&tl=en&text=%s&op=translate", term)
    focusOtherBrowserWindow()
    hs.urlevent.openURL(url)
end)

