local contexts = {}

function contexts.loadWritingContext()

    -- Open writing context in Obsidian
    local writingContextUrl = "obsidian://open?vault=life&file=Areas%2FLeisure%2FWriting%2FWriting%20Context"
    hs.urlevent.openURL(writingContextUrl)

    -- Show alert
    hs.alert.show("Writing context loaded")
end

return contexts

