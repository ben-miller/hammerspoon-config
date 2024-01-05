local log = hs.logger.new("main", "verbose") -- Use 'log.e(xxx)'

local contexts = {}

function hideAllWindows()
    local allWindows = hs.window.allWindows()
    for _, window in ipairs(allWindows) do
        local app = window:application()
        if app then app:hide() end
    end
end

function contexts.loadWritingContext()

    -- Hide all apps
    hideAllWindows()

    -- Open writing context in Obsidian
    local writingContextUrl = "obsidian://open?vault=life&file=Areas%2FLeisure%2FWriting%2FWriting%20Context"
    hs.urlevent.openURL(writingContextUrl)

    -- Open Timer app
    hs.application.launchOrFocus("Timer")

    -- Show alert
    hs.alert.show("Writing context loaded")
end

return contexts

