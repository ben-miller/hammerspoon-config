local log = hs.logger.new("main", "verbose") -- Use 'log.e(xxx)'
local windowmanager = require("windowmanager")

local contexts = {}

-- Get 

function hideAllWindows()
    local allWindows = hs.window.allWindows()
    for _, window in ipairs(allWindows) do
        local app = window:application()
        if app then app:hide() end
    end
end

function contexts.loadWritingContext()

    -- Hide all windows
    hideAllWindows()

    -- Open writing context in Obsidian
    local writingContextUrl = "obsidian://open?vault=life&file=Areas%2FLeisure%2FWriting%2FWriting%20Context"
    hs.urlevent.openURL(writingContextUrl)

    -- Open Timer app
    hs.application.launchOrFocus("Timer")

    -- Show alert
    hs.alert.show("Writing context loaded")
end

function contexts.loadDevContext()
    windowmanager.printScreens()

    -- Hide all windows
    hideAllWindows()

    -- Open dev context in Obsidian
    hs.application.launchOrFocus("Obsidian")
    local devContextUrl = "obsidian://open?vault=life&file=Areas%2FDevelopment%2FDevelopment%20Context"
    hs.urlevent.openURL(devContextUrl)
    windowmanager.moveToRTK()

    -- Open Firefox in main screen
    hs.application.launchOrFocus("Firefox")
    windowmanager.moveToRetina()

    -- Open iTerm
    hs.application.launchOrFocus("iTerm")
    windowmanager.moveToLG()

    -- Show alert
    hs.alert.show("Dev context loaded")
end

-- Debugging shortcut
hs.hotkey.bind(hyper, "2", function()
    hs.alert.show("Debugging shortcut for contexts.lua pressed")
end)

return contexts

